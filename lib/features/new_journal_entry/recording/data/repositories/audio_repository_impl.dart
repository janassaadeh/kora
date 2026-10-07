import 'dart:async';
import 'dart:io';

import 'package:record/record.dart';

import '../../domain/entities/recording_tick.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioRecorder _recorder = AudioRecorder();
  final StreamController<RecordingTick> _tickController =
      StreamController<RecordingTick>.broadcast();

  Timer? _tickTimer;
  Duration _elapsed = Duration.zero;

  @override
  Stream<RecordingTick> get tickStream => _tickController.stream;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<String> startRecording() async {
    final path =
        '${Directory.systemTemp.path}/kora_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 22050,
        numChannels: 1,
        bitRate: 256000,
      ),
      path: path,
    );

    _elapsed = Duration.zero;
    _startTicking();
    return path;
  }

  @override
  Future<void> pauseRecording() async {
    await _recorder.pause();
    _stopTicking();
  }

  @override
  Future<void> resumeRecording() async {
    await _recorder.resume();
    _startTicking();
  }

  @override
  Future<String?> stopRecording() async {
    _stopTicking();
    return _recorder.stop();
  }

  @override
  Future<void> cancelRecording() async {
    _stopTicking();
    await _recorder.stop();
  }

  // ── Private ──────────────────────────────────────────────────────────────

  void _startTicking() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      final amp = await _recorder.getAmplitude();
      final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);
      _elapsed += const Duration(milliseconds: 100);
      _tickController.add(
        RecordingTick(amplitude: normalized, elapsed: _elapsed),
      );
    });
  }

  void _stopTicking() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  void dispose() {
    _stopTicking();
    _tickController.close();
    _recorder.dispose();
  }
}