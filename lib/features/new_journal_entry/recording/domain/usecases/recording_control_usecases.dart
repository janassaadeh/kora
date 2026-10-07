import '../repositories/audio_repository.dart';

class CheckMicrophonePermissionUseCase {
  final AudioRepository _repository;
  const CheckMicrophonePermissionUseCase(this._repository);

  Future<bool> call() => _repository.hasPermission();
}

class PauseRecordingUseCase {
  final AudioRepository _repository;
  const PauseRecordingUseCase(this._repository);

  Future<void> call() => _repository.pauseRecording();
}

class ResumeRecordingUseCase {
  final AudioRepository _repository;
  const ResumeRecordingUseCase(this._repository);

  Future<void> call() => _repository.resumeRecording();
}

class CancelRecordingUseCase {
  final AudioRepository _repository;
  const CancelRecordingUseCase(this._repository);

  Future<void> call() => _repository.cancelRecording();
}