part of 'entry_bloc.dart';

abstract class EntryEvent extends Equatable {
  const EntryEvent();
  @override
  List<Object?> get props => [];
}

class EntryInitialized extends EntryEvent {
  const EntryInitialized();
}

class NextStepRequested extends EntryEvent {
  const NextStepRequested();
}

class PrevStepRequested extends EntryEvent {
  const PrevStepRequested();
}

class WritingReasonsChanged extends EntryEvent {
  final Set<String> reasons;
  const WritingReasonsChanged(this.reasons);
  @override
  List<Object?> get props => [reasons];
}

class ReasonNoteChanged extends EntryEvent {
  final String text;
  const ReasonNoteChanged(this.text);
  @override
  List<Object?> get props => [text];
}

class ContextTextChanged extends EntryEvent {
  final String text;
  const ContextTextChanged(this.text);
  @override
  List<Object?> get props => [text];
}

class EntrySubmitted extends EntryEvent {
  const EntrySubmitted();
}

class SaveDraftRequested extends EntryEvent {
  const SaveDraftRequested();
}

class DraftRestoreRequested extends EntryEvent {
  const DraftRestoreRequested();
}

class DraftDiscarded extends EntryEvent {
  const DraftDiscarded();
}

// Internal — fired by EntryBloc when it snapshots sibling blocs
class _HealthSnapshotReceived extends EntryEvent {
  final HealthState health;
  const _HealthSnapshotReceived(this.health);
  @override
  List<Object?> get props => [health];
}

class _RecordingSnapshotReceived extends EntryEvent {
  final RecordingState recording;
  const _RecordingSnapshotReceived(this.recording);
  @override
  List<Object?> get props => [recording];
}