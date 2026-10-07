part of 'health_bloc.dart';

enum HeartRateScanStatus { idle, scanning, done, failed, skipped }
enum ActivityFetchStatus { idle, loading, done }

class HealthState extends Equatable {
  final int? heartRate;
  final HeartRateScanStatus heartRateStatus;
  final HealthData? activityData;
  final ActivityFetchStatus activityStatus;

  const HealthState({
    this.heartRate,
    this.heartRateStatus = HeartRateScanStatus.idle,
    this.activityData,
    this.activityStatus = ActivityFetchStatus.idle,
  });

  bool get heartRateReady =>
      heartRateStatus == HeartRateScanStatus.done ||
      heartRateStatus == HeartRateScanStatus.skipped;

  HealthState copyWith({
    int? heartRate,
    HeartRateScanStatus? heartRateStatus,
    HealthData? activityData,
    ActivityFetchStatus? activityStatus,
  }) =>
      HealthState(
        heartRate: heartRate ?? this.heartRate,
        heartRateStatus: heartRateStatus ?? this.heartRateStatus,
        activityData: activityData ?? this.activityData,
        activityStatus: activityStatus ?? this.activityStatus,
      );

  @override
  List<Object?> get props => [
        heartRate,
        heartRateStatus,
        activityData,
        activityStatus,
      ];
}