import '../../domain/entities/health_data.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_local_datasource.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthLocalDataSource _local;

  const HealthRepositoryImpl(this._local);

  @override
  Future<void> requestPermissions() => _local.requestPermissions();

  @override
  Future<int?> fetchStepsToday() => _local.fetchStepsToday();

  @override
  Future<int?> fetchLatestHeartRate() => _local.fetchLatestHeartRate();

  @override
  Future<int?> fetchCaloriesToday() => _local.fetchCaloriesToday();

  @override
  Future<int?> fetchActivityMinutesToday() =>
      _local.fetchActivityMinutesToday();

  @override
  Future<HealthData> fetchAll() async {
    final results = await Future.wait([
      _local.fetchStepsToday(),
      _local.fetchLatestHeartRate(),
      _local.fetchCaloriesToday(),
      _local.fetchActivityMinutesToday(),
    ]);

    return HealthData(
      totalSteps: (results[0] as int?) ?? 0,
      stepGoal: 10000,
      heartRate: (results[1] as int?) ?? 0,
      calories: (results[2] as int?) ?? 0,
      activityMinutes: (results[3] as int?) ?? 0,
    );
  }
}