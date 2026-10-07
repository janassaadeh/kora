import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/features/new_journal_entry/recording/domain/entities/recording_result.dart';
import 'package:kora/features/new_journal_entry/recording/domain/entities/recording_tick.dart';
import 'package:kora/features/new_journal_entry/recording/domain/usecases/recording_control_usecases.dart';
import 'package:kora/features/new_journal_entry/recording/domain/usecases/start_recording_usecase.dart';
import 'package:kora/features/new_journal_entry/recording/domain/usecases/stop_recording_usecase.dart';
import 'package:kora/features/new_journal_entry/recording/domain/usecases/watch_recording_ticks_usecase.dart';

part 'recording_event.dart';
part 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final StartRecordingUseCase _start;
  final StopRecordingUseCase _stop;
  final PauseRecordingUseCase _pause;
  final ResumeRecordingUseCase _resume;
  final CancelRecordingUseCase _cancel;
  final CheckMicrophonePermissionUseCase _checkMicPermission;
  final WatchRecordingTicksUseCase _watchTicks;

  RecordingBloc({
    required StartRecordingUseCase start,
    required StopRecordingUseCase stop,
    required PauseRecordingUseCase pause,
    required ResumeRecordingUseCase resume,
    required CancelRecordingUseCase cancel,
    required CheckMicrophonePermissionUseCase checkMicPermission,
    required WatchRecordingTicksUseCase watchTicks,
  })  : _start = start,
        _stop = stop,
        _pause = pause,
        _resume = resume,
        _cancel = cancel,
        _checkMicPermission = checkMicPermission,
        _watchTicks = watchTicks,
        super(const RecordingState()) {
    on<RecordingStarted>(_onStart);
    on<RecordingPaused>(_onPause);
    on<RecordingResumed>(_onResume);
    on<RecordingFinished>(_onFinish);
    on<RecordingCancelled>(_onCancel);
    on<_RecordingTickReceived>(_onTick);
  }

  Future<void> _onStart(
      RecordingStarted e, Emitter<RecordingState> emit) async {
    final hasPermission = await _checkMicPermission();
    if (!hasPermission) {
      debugPrint('⚠️ Microphone permission denied');
      return;
    }

    final path = await _start();

    emit(state.copyWith(
      status: RecordingStatus.recording,
      duration: Duration.zero,
      amplitudeSamples: List.filled(15, 0.0),
      filePath: path,
    ));

    await emit.forEach(
      _watchTicks(),
      onData: (tick) {
        final samples = [...state.amplitudeSamples];
        if (samples.length >= 15) samples.removeAt(0);
        samples.add(tick.amplitude);
        return state.copyWith(
          duration: tick.elapsed,
          amplitudeSamples: samples,
        );
      },
    );
  }

  Future<void> _onPause(
      RecordingPaused e, Emitter<RecordingState> emit) async {
    await _pause();
    emit(state.copyWith(status: RecordingStatus.paused));
  }

  Future<void> _onResume(
      RecordingResumed e, Emitter<RecordingState> emit) async {
    await _resume();
    emit(state.copyWith(status: RecordingStatus.recording));
  }

  Future<void> _onFinish(
      RecordingFinished e, Emitter<RecordingState> emit) async {
    if (state.status != RecordingStatus.recording &&
        state.status != RecordingStatus.paused) return;

    emit(state.copyWith(status: RecordingStatus.done));

    final result = await _stop();
    emit(state.copyWith(
      filePath: result.path,
      detectedEmotion: result.detectedEmotion,
      emotionConfidence: result.emotionConfidence,
      recordingCurve: result.curve,
    ));
  }

  Future<void> _onCancel(
      RecordingCancelled e, Emitter<RecordingState> emit) async {
    await _cancel();
    emit(const RecordingState());
  }

  void _onTick(_RecordingTickReceived e, Emitter<RecordingState> emit) {
    final samples = [...state.amplitudeSamples];
    if (samples.length >= 15) samples.removeAt(0);
    samples.add(e.tick.amplitude);
    emit(state.copyWith(
      duration: e.tick.elapsed,
      amplitudeSamples: samples,
    ));
  }
}