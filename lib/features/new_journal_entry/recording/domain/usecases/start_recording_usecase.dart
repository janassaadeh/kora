import '../repositories/audio_repository.dart';

class StartRecordingUseCase {
  final AudioRepository _repository;
  const StartRecordingUseCase(this._repository);

  Future<String> call() => _repository.startRecording();
}