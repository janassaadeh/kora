import '../entities/recording_tick.dart';
import '../repositories/audio_repository.dart';

class WatchRecordingTicksUseCase {
  final AudioRepository _repository;
  const WatchRecordingTicksUseCase(this._repository);

  Stream<RecordingTick> call() => _repository.tickStream;
}