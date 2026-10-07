import '../entities/health_data.dart';
import '../repositories/health_repository.dart';

class FetchActivityUseCase {
  final HealthRepository _repository;
  const FetchActivityUseCase(this._repository);

  /// [scannedHeartRate] is carried over from the heart-rate step so the
  /// activity summary uses the value already shown to the user.
  Future<HealthData> call({int? scannedHeartRate}) async {
    final data = await _repository.fetchAll();
    if (scannedHeartRate == null) return data;

    return HealthData(
      totalSteps: data.totalSteps,
      stepGoal: data.stepGoal,
      heartRate: scannedHeartRate,
      calories: data.calories,
      activityMinutes: data.activityMinutes,
    );
  }
}