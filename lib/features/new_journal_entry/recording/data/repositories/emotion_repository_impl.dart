import 'package:kora/features/new_journal_entry/recording/data/datasources/emotion_local_datasource.dart';
// import 'package:kora/features/new_journal_entry/data/services/emotion_service.dart' hide EmotionResult;

import '../../domain/entities/emotion_result.dart';
import '../../domain/repositories/emotion_repository.dart';
// import '../services/emotion_service.dart';

class EmotionRepositoryImpl implements EmotionRepository {
  final EmotionLocalDataSource _local;

  const EmotionRepositoryImpl(this._local);

  @override
  Future<void> initialize() => _local.initialize();

  @override
  Future<EmotionResult> predict(String audioPath) async {
    final raw = await _local.predict(audioPath);
    // Map the data-layer EmotionResult → domain EmotionResult
    return EmotionResult(
      emotion: raw.emotion,
      confidence: raw.confidence,
      allProbabilities: raw.allProbabilities,
    );
  }

  @override
  Future<List<double>> extractSpectrogramCurve(String audioPath) async =>
      _local.extractSpectrogramCurve(audioPath);
}