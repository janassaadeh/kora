import '../entities/recording_result.dart';
import '../repositories/audio_repository.dart';
import 'detect_emotion_usecase.dart';
// import 'extract_spectrogram_curve_usecase.dart';

/// Stops the active recording and runs emotion detection + spectrogram
/// extraction on the resulting file. Returns a [RecordingResult] with all
/// derived data bundled together so the bloc receives one clean value.
class StopRecordingUseCase {
  final AudioRepository _repository;
  final DetectEmotionUseCase _detectEmotion;
  final ExtractSpectrogramCurveUseCase _extractCurve;

  const StopRecordingUseCase({
    required AudioRepository repository,
    required DetectEmotionUseCase detectEmotion,
    required ExtractSpectrogramCurveUseCase extractCurve,
  })  : _repository = repository,
        _detectEmotion = detectEmotion,
        _extractCurve = extractCurve;

  Future<RecordingResult> call() async {
    final path = await _repository.stopRecording();
    if (path == null) return RecordingResult.empty();

    // Run in parallel — neither depends on the other.
    final results = await Future.wait([
      _detectEmotion(path),
      _extractCurve(path),
    ]);

    final emotionResult = results[0] as dynamic;
    final curve = results[1] as List<double>;

    return RecordingResult(
      path: path,
      detectedEmotion: emotionResult?.emotion as String?,
      emotionConfidence: emotionResult?.confidence as double?,
      curve: curve,
    );
  }
}