part of 'entry_bloc.dart';

class EntryState extends Equatable {
  final EntryStep step;
  final Set<String> selectedReasons;
  final String reasonNote;
  final String contextText;
  final double? sentimentScore;
  final int? vitalityScore;
  final String? locationCity;
  final bool locationLoading;
  final bool hasSavedDraft;
  final bool loadingDraft;
  final bool draftJustSaved;
  final bool saving;
  final bool saved;
  final NewEntry? lastSavedEntry;

  // Snapshots pulled from sibling blocs at submission / vitality time
  final HealthState? healthSnapshot;
  final RecordingState? recordingSnapshot;

  const EntryState({
    this.step = EntryStep.reason,
    this.selectedReasons = const {},
    this.reasonNote = '',
    this.contextText = '',
    this.sentimentScore,
    this.vitalityScore,
    this.locationCity,
    this.locationLoading = true,
    this.hasSavedDraft = false,
    this.loadingDraft = false,
    this.draftJustSaved = false,
    this.saving = false,
    this.saved = false,
    this.lastSavedEntry,
    this.healthSnapshot,
    this.recordingSnapshot,
  });

  EntryState copyWith({
    EntryStep? step,
    Set<String>? selectedReasons,
    String? reasonNote,
    String? contextText,
    double? sentimentScore,
    int? vitalityScore,
    String? locationCity,
    bool? locationLoading,
    bool? hasSavedDraft,
    bool? loadingDraft,
    bool? draftJustSaved,
    bool? saving,
    bool? saved,
    NewEntry? lastSavedEntry,
    HealthState? healthSnapshot,
    RecordingState? recordingSnapshot,
  }) =>
      EntryState(
        step: step ?? this.step,
        selectedReasons: selectedReasons ?? this.selectedReasons,
        reasonNote: reasonNote ?? this.reasonNote,
        contextText: contextText ?? this.contextText,
        sentimentScore: sentimentScore ?? this.sentimentScore,
        vitalityScore: vitalityScore ?? this.vitalityScore,
        locationCity: locationCity ?? this.locationCity,
        locationLoading: locationLoading ?? this.locationLoading,
        hasSavedDraft: hasSavedDraft ?? this.hasSavedDraft,
        loadingDraft: loadingDraft ?? this.loadingDraft,
        draftJustSaved: draftJustSaved ?? this.draftJustSaved,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
        lastSavedEntry: lastSavedEntry ?? this.lastSavedEntry,
        healthSnapshot: healthSnapshot ?? this.healthSnapshot,
        recordingSnapshot: recordingSnapshot ?? this.recordingSnapshot,
      );

  @override
  List<Object?> get props => [
        step,
        selectedReasons,
        reasonNote,
        contextText,
        sentimentScore,
        vitalityScore,
        locationCity,
        locationLoading,
        hasSavedDraft,
        loadingDraft,
        draftJustSaved,
        saving,
        saved,
        lastSavedEntry,
        healthSnapshot,
        recordingSnapshot,
      ];
}