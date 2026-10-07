import '../../domain/entities/entry_draft.dart';

class EntryDraftModel extends EntryDraft {
  const EntryDraftModel({
    required super.stepIndex,
    required super.reasonNote,
    required super.contextText,
    super.selectedReasons,
    super.heartRate,
    super.activityData,
  });

  factory EntryDraftModel.fromEntity(EntryDraft draft) {
    return EntryDraftModel(
      stepIndex: draft.stepIndex,
      reasonNote: draft.reasonNote,
      contextText: draft.contextText,
      selectedReasons: draft.selectedReasons,
      heartRate: draft.heartRate,
      activityData: draft.activityData,
    );
  }
}