import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:kora/features/new_journal_entry/recording/domain/entities/emotion_result.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:fftea/fftea.dart';

class EmotionLocalDataSource {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // FIX: this must match the sample rate the training pipeline used
  // (SR = 16000 in the Colab notebook's main feature-extraction pass).
  // Do NOT change this without retraining — it defines the Mel filterbank's
  // frequency range (0 .. targetSampleRate/2).
  static const int targetSampleRate = 16000;

  static const int nMels = 128;
  static const int maxLen = 128;
  static const int nFft = 2048;
  static const int hopLength = 512;

  Future<void> initialize() async {
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    _labels = labelsData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    _interpreter = await Interpreter.fromAsset('assets/ser_model.tflite');
  }

  /// Parse WAV file, returning raw PCM samples AND the file's real sample rate.
  /// FIX: previously this ignored the WAV header's sample rate entirely and
  /// assumed a hardcoded constant. Now we read it directly from the header.
  ({Float32List samples, int sampleRate}) _loadWav(String path) {
    final bytes = File(path).readAsBytesSync();
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

    // Standard WAV header: sample rate is a 4-byte little-endian int at byte 24.
    // (Assumes a canonical 44-byte header with no extra chunks before 'data',
    // same assumption the original code made — fine for files this app itself
    // records, but flag in the thesis if you ever ingest arbitrary WAVs.)
    final fileSampleRate = byteData.getUint32(24, Endian.little);

    const headerSize = 44;
    final numSamples = (bytes.length - headerSize) ~/ 2;
    final samples = Float32List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final raw = byteData.getInt16(headerSize + i * 2, Endian.little);
      samples[i] = raw / 32768.0;
    }

    return (samples: samples, sampleRate: fileSampleRate);
  }

  /// FIX (new): resample audio to targetSampleRate using linear interpolation.
  /// This is a lightweight resampler — no anti-aliasing low-pass filter —
  /// which is a reasonable trade-off for a mobile app and worth naming as a
  /// stated simplification in the thesis (proper resampling would use a
  /// windowed-sinc filter, e.g. what librosa/soxr do on the Python side).
  Float32List _resample(Float32List input, int fromRate, int toRate) {
    if (fromRate == toRate) return input;

    final ratio = toRate / fromRate;
    final outLength = (input.length * ratio).round();
    final output = Float32List(outLength);

    for (int i = 0; i < outLength; i++) {
      final srcPos = i / ratio;
      final srcIndexLow = srcPos.floor();
      final srcIndexHigh = min(srcIndexLow + 1, input.length - 1);
      final frac = srcPos - srcIndexLow;

      if (srcIndexLow >= input.length) {
        output[i] = input[input.length - 1];
      } else {
        output[i] = input[srcIndexLow] * (1 - frac) + input[srcIndexHigh] * frac;
      }
    }

    return output;
  }

  /// Build a triangular mel filter bank
  List<Float32List> _buildMelFilterbank(int nFilt, int nFft, int sr) {
    double hzToMel(double hz) => 2595 * log(1 + hz / 700) / ln10;
    double melToHz(double mel) => 700 * (pow(10, mel / 2595) - 1);

    final lowMel = hzToMel(0);
    final highMel = hzToMel(sr / 2.0);
    final melPoints = List.generate(
        nFilt + 2, (i) => melToHz(lowMel + i * (highMel - lowMel) / (nFilt + 1)));
    final bins = melPoints.map((hz) => (hz * (nFft / 2 + 1) / (sr / 2)).floor()).toList();

    final filterbank = List.generate(nFilt, (m) {
      final f = Float32List(nFft ~/ 2 + 1);
      for (int k = bins[m]; k < bins[m + 1]; k++) {
        f[k] = (k - bins[m]) / (bins[m + 1] - bins[m]);
      }
      for (int k = bins[m + 1]; k < bins[m + 2]; k++) {
        f[k] = (bins[m + 2] - k) / (bins[m + 2] - bins[m + 1]);
      }
      return f;
    });
    return filterbank;
  }

  /// Compute mel-spectrogram in dB, shape [nMels, maxLen]
  /// FIX: now takes sampleRate explicitly (always targetSampleRate after
  /// resampling) instead of relying on a module-level constant that could
  /// drift out of sync with what was actually used.
  List<List<double>> _computeMelSpectrogram(Float32List audio, int sampleRate) {
    final fft = FFT(nFft);
    final filterbank = _buildMelFilterbank(nMels, nFft, sampleRate);

    final window = Float32List(nFft);
    for (int i = 0; i < nFft; i++) {
      window[i] = 0.5 * (1 - cos(2 * pi * i / (nFft - 1)));
    }

    final numFrames = (audio.length - nFft) ~/ hopLength + 1;
    final melFrames = List.generate(nMels, (_) => List.filled(max(numFrames, 0), 0.0));

    for (int t = 0; t < numFrames; t++) {
      final start = t * hopLength;
      if (start + nFft > audio.length) break;

      final frame = Float64List(nFft);
      for (int i = 0; i < nFft; i++) {
        frame[i] = audio[start + i] * window[i];
      }

      final spectrum = fft.realFft(frame);

      final power = Float64List(nFft ~/ 2 + 1);
      for (int i = 0; i <= nFft ~/ 2; i++) {
        final re = spectrum[i].x;
        final im = spectrum[i].y;
        power[i] = re * re + im * im;
      }

      for (int m = 0; m < nMels; m++) {
        double val = 0.0;
        for (int k = 0; k < filterbank[m].length; k++) {
          val += filterbank[m][k] * power[k];
        }
        melFrames[m][t] = val;
      }
    }

    double maxVal = double.negativeInfinity;
    for (int m = 0; m < nMels; m++) {
      for (int t = 0; t < numFrames; t++) {
        if (melFrames[m][t] > maxVal) maxVal = melFrames[m][t];
      }
    }
    final refVal = maxVal < 1e-10 ? 1e-10 : maxVal;

    final melDb = List.generate(nMels, (m) {
      return List.generate(numFrames, (t) {
        final val = melFrames[m][t] < 1e-10 ? 1e-10 : melFrames[m][t];
        return 10 * log(val / refVal) / ln10;
      });
    });

    return melDb;
  }

  Float32List _prepareInput(List<List<double>> melDb) {
    final input = Float32List(nMels * maxLen);
    for (int m = 0; m < nMels; m++) {
      for (int t = 0; t < maxLen; t++) {
        final val = t < melDb[m].length ? melDb[m][t] : 0.0;
        input[m * maxLen + t] = val.toDouble();
      }
    }
    return input;
  }

  Future<EmotionResult> predict(String audioPath) async {
    if (_interpreter == null) {
      throw Exception('Model not initialized. Call initialize() first.');
    }
    final totalStopwatch = Stopwatch()..start();

    // Load audio + its real sample rate from the WAV header
    final loaded = _loadWav(audioPath);

    // FIX: resample to match training (16000 Hz) if the recorded file
    // is at a different native rate (e.g. 44100/48000 from the device mic)
    final audio = _resample(loaded.samples, loaded.sampleRate, targetSampleRate);

    // Compute mel spectrogram at the matched sample rate
    final melDb = _computeMelSpectrogram(audio, targetSampleRate);

    final flatInput = _prepareInput(melDb);
    final inputTensor = List.generate(
      1,
      (_) => List.generate(
        nMels,
        (m) => List.generate(
          maxLen,
          (t) => [flatInput[m * maxLen + t]],
        ),
      ),
    );

       final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
    final inferenceStopwatch = Stopwatch()..start();
    _interpreter!.run(inputTensor, output);
    inferenceStopwatch.stop();

    totalStopwatch.stop();
    print('SER preprocessing+inference total: ${totalStopwatch.elapsedMilliseconds} ms, '
          'model inference only: ${inferenceStopwatch.elapsedMilliseconds} ms');

    final probs = output[0];
    // ...rest continues normally
    int maxIdx = 0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > probs[maxIdx]) maxIdx = i;
    }

    final allProbs = <String, double>{};
    for (int i = 0; i < _labels.length; i++) {
      allProbs[_labels[i]] = probs[i];
    }

    return EmotionResult(
      emotion: _labels[maxIdx],
      confidence: probs[maxIdx],
      allProbabilities: allProbs,
    );
  }

  List<double> extractSpectrogramCurve(String path) {
    final loaded = _loadWav(path);
    final audio = _resample(loaded.samples, loaded.sampleRate, targetSampleRate);
    final melDb = _computeMelSpectrogram(audio, targetSampleRate);

    final nMelsLocal = melDb.length;
    final nFrames = melDb[0].length;

    final curve = List<double>.filled(nFrames, 0.0);

    for (int t = 0; t < nFrames; t++) {
      double energy = 0;
      for (int m = 0; m < nMelsLocal; m++) {
        energy += melDb[m][t];
      }
      curve[t] = energy;
    }

    return curve;
  }
}