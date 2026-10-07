import '../entities/health_data.dart';
import '../repositories/health_repository.dart';

class FetchHealthDataUseCase {
  final HealthRepository _repository;

  const FetchHealthDataUseCase(this._repository);

  Future<HealthData> call() => _repository.fetchAll();
}

class FetchHeartRateUseCase {
  final HealthRepository _repository;

  const FetchHeartRateUseCase(this._repository);

  Future<int?> call() => _repository.fetchLatestHeartRate();
}

class RequestHealthPermissionsUseCase {
  final HealthRepository _repository;

  const RequestHealthPermissionsUseCase(this._repository);

  Future<void> call() => _repository.requestPermissions();
}