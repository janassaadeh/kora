class EntryDraft {
  final int stepIndex;
  final String reasonNote;
  final String contextText;
  final Set<String> selectedReasons;
  final int? heartRate;
  final Map<String, dynamic>? activityData;

  const EntryDraft({
    required this.stepIndex,
    required this.reasonNote,
    required this.contextText,
    this.selectedReasons = const {},
    this.heartRate,
    this.activityData,
  });
}