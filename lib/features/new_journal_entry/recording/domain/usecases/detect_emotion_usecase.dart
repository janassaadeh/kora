import '../entities/emotion_result.dart';
import '../repositories/emotion_repository.dart';

class DetectEmotionUseCase {
  final EmotionRepository _repository;

  const DetectEmotionUseCase(this._repository);

  Future<EmotionResult> call(String audioPath) =>
      _repository.predict(audioPath);
}

class ExtractSpectrogramCurveUseCase {
  final EmotionRepository _repository;

  const ExtractSpectrogramCurveUseCase(this._repository);

  Future<List<double>> call(String audioPath) =>
      _repository.extractSpectrogramCurve(audioPath);
}