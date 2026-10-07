import '../repositories/health_repository.dart';

class RequestHealthPermissionsUseCase {
  final HealthRepository _repository;
  const RequestHealthPermissionsUseCase(this._repository);

  Future<void> call() => _repository.requestPermissions();
}