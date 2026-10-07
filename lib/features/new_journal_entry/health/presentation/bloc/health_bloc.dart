import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/features/new_journal_entry/health/domain/entities/health_data.dart';
import 'package:kora/features/new_journal_entry/health/domain/usecases/fetch_activity_usecase.dart';
import 'package:kora/features/new_journal_entry/health/domain/usecases/fetch_health_data_usecases.dart';
// import 'package:kora/features/new_journal_entry/health/domain/usecases/fetch_heart_rate_usecase.dart';

part 'health_event.dart';
part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final FetchHeartRateUseCase _fetchHeartRate;
  final FetchActivityUseCase _fetchActivity;
  final RequestHealthPermissionsUseCase _requestPermissions;

  HealthBloc({
    required FetchHeartRateUseCase fetchHeartRate,
    required FetchActivityUseCase fetchActivity,
    required RequestHealthPermissionsUseCase requestPermissions,
  })  : _fetchHeartRate = fetchHeartRate,
        _fetchActivity = fetchActivity,
        _requestPermissions = requestPermissions,
        super(const HealthState()) {
    on<HealthInitialized>(_onInit);
    on<HeartRateScanRequested>(_onScan);
    on<HeartRateManuallyEntered>(_onManualEntry);
    on<HeartRateSkipped>(_onSkipped);
    on<ActivityFetchRequested>(_onFetchActivity);
  }

  Future<void> _onInit(
      HealthInitialized e, Emitter<HealthState> emit) async {
    await _requestPermissions();
  }

  Future<void> _onScan(
      HeartRateScanRequested e, Emitter<HealthState> emit) async {
    emit(state.copyWith(heartRateStatus: HeartRateScanStatus.scanning));
    final bpm = await _fetchHeartRate();
    if (bpm != null) {
      emit(state.copyWith(
        heartRate: bpm,
        heartRateStatus: HeartRateScanStatus.done,
      ));
    } else {
      emit(state.copyWith(heartRateStatus: HeartRateScanStatus.failed));
    }
  }

  void _onManualEntry(
      HeartRateManuallyEntered e, Emitter<HealthState> emit) {
    emit(state.copyWith(
      heartRate: e.bpm,
      heartRateStatus: HeartRateScanStatus.done,
    ));
  }

  void _onSkipped(HeartRateSkipped e, Emitter<HealthState> emit) {
    emit(state.copyWith(heartRateStatus: HeartRateScanStatus.skipped));
  }

  Future<void> _onFetchActivity(
      ActivityFetchRequested e, Emitter<HealthState> emit) async {
    emit(state.copyWith(activityStatus: ActivityFetchStatus.loading));
    final data = await _fetchActivity(scannedHeartRate: state.heartRate);
    emit(state.copyWith(
      activityData: data,
      activityStatus: ActivityFetchStatus.done,
    ));
  }
}