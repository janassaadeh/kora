part of 'health_bloc.dart';

abstract class HealthEvent extends Equatable {
  const HealthEvent();
  @override
  List<Object?> get props => [];
}

class HealthInitialized extends HealthEvent {
  const HealthInitialized();
}

class HeartRateScanRequested extends HealthEvent {
  const HeartRateScanRequested();
}

class HeartRateManuallyEntered extends HealthEvent {
  final int bpm;
  const HeartRateManuallyEntered(this.bpm);
  @override
  List<Object?> get props => [bpm];
}

class HeartRateSkipped extends HealthEvent {
  const HeartRateSkipped();
}

class ActivityFetchRequested extends HealthEvent {
  const ActivityFetchRequested();
}