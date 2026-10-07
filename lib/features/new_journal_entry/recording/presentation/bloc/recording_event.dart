part of 'recording_bloc.dart';

abstract class RecordingEvent extends Equatable {
  const RecordingEvent();
  @override
  List<Object?> get props => [];
}

class RecordingStarted extends RecordingEvent {
  const RecordingStarted();
}

class RecordingPaused extends RecordingEvent {
  const RecordingPaused();
}

class RecordingResumed extends RecordingEvent {
  const RecordingResumed();
}

class RecordingFinished extends RecordingEvent {
  const RecordingFinished();
}

class RecordingCancelled extends RecordingEvent {
  const RecordingCancelled();
}

class _RecordingTickReceived extends RecordingEvent {
  final RecordingTick tick;
  const _RecordingTickReceived(this.tick);
  @override
  List<Object?> get props => [tick];
}