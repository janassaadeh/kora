import '../entities/emotion_result.dart';

abstract class EmotionRepository {
  Future<void> initialize();
  Future<EmotionResult> predict(String audioPath);
  Future<List<double>> extractSpectrogramCurve(String audioPath);
}