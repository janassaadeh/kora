import '../entities/health_data.dart';

abstract class HealthRepository {
  Future<void> requestPermissions();
  Future<int?> fetchStepsToday();
  Future<int?> fetchLatestHeartRate();
  Future<int?> fetchCaloriesToday();
  Future<int?> fetchActivityMinutesToday();
  Future<HealthData> fetchAll();
}