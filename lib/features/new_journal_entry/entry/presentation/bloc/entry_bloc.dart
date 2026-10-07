import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/features/new_journal_entry/entry/domain/entities/entry_draft.dart';
import 'package:kora/features/new_journal_entry/entry/domain/entities/new_entry.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/analyze_sentiment_usecase.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/calculate_viatlity_usecase.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/draft_usecases.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/resolve_location_usecase.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/save_entry.dart';
import 'package:kora/features/new_journal_entry/health/presentation/bloc/health_bloc.dart';
// import 'package:kora/features/new_journal_entry/presentation/bloc/new_entry_bloc.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/bloc/recording_bloc.dart';
import 'package:kora/features/new_journal_entry/shared/entities/entry_step.dart';

part 'entry_event.dart';
part 'entry_state.dart';

class EntryBloc extends Bloc<EntryEvent, EntryState> {
  final SaveEntryUseCase _saveEntry;
  final SaveDraftUseCase _saveDraft;
  final LoadDraftUseCase _loadDraft;
  final ClearDraftUseCase _clearDraft;
  final HasDraftUseCase _hasDraft;
  final ResolveLocationUseCase _resolveLocation;
  final AnalyzeSentimentUseCase _analyzeSentiment;
  final CalculateVitalityUseCase _calculateVitality;

  // Sibling blocs — read-only snapshots, never mutated here
  final HealthBloc _healthBloc;
  final RecordingBloc _recordingBloc;

  EntryBloc({
    required SaveEntryUseCase saveEntry,
    required SaveDraftUseCase saveDraft,
    required LoadDraftUseCase loadDraft,
    required ClearDraftUseCase clearDraft,
    required HasDraftUseCase hasDraft,
    required ResolveLocationUseCase resolveLocation,
    required AnalyzeSentimentUseCase analyzeSentiment,
    required CalculateVitalityUseCase calculateVitality,
    required HealthBloc healthBloc,
    required RecordingBloc recordingBloc,
  })  : _saveEntry = saveEntry,
        _saveDraft = saveDraft,
        _loadDraft = loadDraft,
        _clearDraft = clearDraft,
        _hasDraft = hasDraft,
        _resolveLocation = resolveLocation,
        _analyzeSentiment = analyzeSentiment,
        _calculateVitality = calculateVitality,
        _healthBloc = healthBloc,
        _recordingBloc = recordingBloc,
        super(const EntryState()) {
    on<EntryInitialized>(_onInit);
    on<NextStepRequested>(_onNext);
    on<PrevStepRequested>(_onPrev);
    on<WritingReasonsChanged>(_onReasonsChanged);
    on<ReasonNoteChanged>(_onReasonNoteChanged);
    on<ContextTextChanged>(_onContextChanged);
    on<EntrySubmitted>(_onSubmit);
    on<SaveDraftRequested>(_onSaveDraft);
    on<DraftRestoreRequested>(_onRestoreDraft);
    on<DraftDiscarded>(_onDiscardDraft);
    on<_HealthSnapshotReceived>(_onHealthSnapshot);
    on<_RecordingSnapshotReceived>(_onRecordingSnapshot);
  }

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> _onInit(
      EntryInitialized e, Emitter<EntryState> emit) async {
    final results = await Future.wait([
      _hasDraft(),
      _resolveLocation(),
    ]);

    emit(state.copyWith(
      hasSavedDraft: results[0] as bool,
      locationCity: results[1] as String?,
      locationLoading: false,
    ));
  }

  // ── Sibling snapshots ──────────────────────────────────────────────────────

  void _onHealthSnapshot(
      _HealthSnapshotReceived e, Emitter<EntryState> emit) {
    emit(state.copyWith(healthSnapshot: e.health));
  }

  void _onRecordingSnapshot(
      _RecordingSnapshotReceived e, Emitter<EntryState> emit) {
    emit(state.copyWith(recordingSnapshot: e.recording));
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
Future<void> _onNext(
    NextStepRequested e, Emitter<EntryState> emit) async {
  final steps = EntryStep.values;
  final idx = steps.indexOf(state.step);
  if (idx >= steps.length - 1) return;

  if (state.step == EntryStep.context && state.contextText.isNotEmpty) {
    try {
      final score = _analyzeSentiment(state.contextText);
      emit(state.copyWith(sentimentScore: score));
    } catch (_) {}
  }

  final next = steps[idx + 1];
  emit(state.copyWith(step: next));

  if (next == EntryStep.heartRate) {
    _healthBloc.add(const HeartRateScanRequested());
  }
  if (next == EntryStep.activity) {
    add(_HealthSnapshotReceived(_healthBloc.state));
    _healthBloc.add(const ActivityFetchRequested());
  }
  if (next == EntryStep.results) {
  add(_HealthSnapshotReceived(_healthBloc.state));
  add(_RecordingSnapshotReceived(_recordingBloc.state));
  _applyVitality(emit);
  add(const EntrySubmitted()); // ← add this
}
}
  void _onPrev(PrevStepRequested e, Emitter<EntryState> emit) {
    final steps = EntryStep.values;
    final idx = steps.indexOf(state.step);
    if (idx <= 0) return;
    emit(state.copyWith(step: steps[idx - 1]));
  }

  // ── Vitality ───────────────────────────────────────────────────────────────

  void _applyVitality(Emitter<EntryState> emit) {
    final health = _healthBloc.state;
    final recording = _recordingBloc.state;

    final score = _calculateVitality(
      heartRate: health.heartRate,
      totalSteps: health.activityData?.totalSteps ?? 0,
      detectedEmotion: recording.detectedEmotion,
      sentimentScore: state.sentimentScore,
    );
    emit(state.copyWith(vitalityScore: score));
  }

  // ── Text fields ────────────────────────────────────────────────────────────

  void _onReasonsChanged(
      WritingReasonsChanged e, Emitter<EntryState> emit) {
    emit(state.copyWith(selectedReasons: e.reasons));
  }

  void _onReasonNoteChanged(
      ReasonNoteChanged e, Emitter<EntryState> emit) {
    emit(state.copyWith(reasonNote: e.text));
  }

  void _onContextChanged(
      ContextTextChanged e, Emitter<EntryState> emit) {
    emit(state.copyWith(contextText: e.text));
  }

  // ── Submission ─────────────────────────────────────────────────────────────

  Future<void> _onSubmit(
      EntrySubmitted e, Emitter<EntryState> emit) async {
    emit(state.copyWith(saving: true));

    final health = _healthBloc.state;
    final recording = _recordingBloc.state;

    final vitalityScore = state.vitalityScore ??
        _calculateVitality(
          heartRate: health.heartRate,
          totalSteps: health.activityData?.totalSteps ?? 0,
          detectedEmotion: recording.detectedEmotion,
          sentimentScore: state.sentimentScore,
        );

    final entry = NewEntry(
      textContextScore: state.sentimentScore ?? 0.0,
      recordingCurve: recording.recordingCurve, 
      heartRate: health.heartRate,
      totalSteps: health.activityData?.totalSteps,
        reasons: state.selectedReasons.isEmpty
          ? (state.reasonNote.isEmpty ? null : [state.reasonNote])
          : state.selectedReasons.toList(),
      recordingAnalysis: recording.detectedEmotion,
      vitalityScore: vitalityScore,
      locationCity: state.locationCity,
      createdAt: DateTime.now(),
    );

    final id = await _saveEntry(entry);
    await _clearDraft();

    emit(state.copyWith(
      saving: false,
      saved: true,
      hasSavedDraft: false,
      lastSavedEntry: entry.copyWith(id: id),
    ));
  }

  // ── Drafts ─────────────────────────────────────────────────────────────────

  Future<void> _onSaveDraft(
      SaveDraftRequested e, Emitter<EntryState> emit) async {
    final health = _healthBloc.state;

    final draft = EntryDraft(
      stepIndex: state.step.index,
      reasonNote: state.reasonNote,
      contextText: state.contextText,
      selectedReasons: state.selectedReasons,
      heartRate: health.heartRate,
      activityData: health.activityData != null
          ? {
              'totalSteps': health.activityData!.totalSteps,
              'calories': health.activityData!.calories,
              'activityMinutes': health.activityData!.activityMinutes,
            }
          : null,
    );

    await _saveDraft(draft);
    emit(state.copyWith(hasSavedDraft: true, draftJustSaved: true));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(draftJustSaved: false));
  }

  Future<void> _onRestoreDraft(
      DraftRestoreRequested e, Emitter<EntryState> emit) async {
    emit(state.copyWith(loadingDraft: true));

    final draft = await _loadDraft();
    if (draft == null) {
      emit(state.copyWith(loadingDraft: false, hasSavedDraft: false));
      return;
    }

    final steps = EntryStep.values;
    final restoredStep =
        steps[draft.stepIndex.clamp(0, steps.length - 1)];

    emit(state.copyWith(
      step: restoredStep,
      reasonNote: draft.reasonNote,
      contextText: draft.contextText,
      selectedReasons: draft.selectedReasons,
      loadingDraft: false,
      hasSavedDraft: false,
    ));

    // Trigger sibling blocs to re-fetch if needed
    if (draft.heartRate != null) {
      _healthBloc.add(HeartRateManuallyEntered(draft.heartRate!));
    }
    if (restoredStep == EntryStep.heartRate) {
      _healthBloc.add(const HeartRateScanRequested());
    }
    if (restoredStep == EntryStep.activity) {
      _healthBloc.add(const ActivityFetchRequested());
    }
    if (restoredStep == EntryStep.results) {
      _applyVitality(emit);
    }
  }

  Future<void> _onDiscardDraft(
      DraftDiscarded e, Emitter<EntryState> emit) async {
    await _clearDraft();
    emit(const EntryState());
  }
}