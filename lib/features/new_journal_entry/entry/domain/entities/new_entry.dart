class NewEntry {
  final String? id;

  final double? textContextScore;
  final int? heartRate;
  final int? totalSteps;
  final int? vitalityScore;
  final DateTime createdAt;

  final List<String>? reasons;
  final String? recordingAnalysis;
  final List<double>? recordingCurve;
  final String? locationCity;

  const NewEntry({
    this.id,
    this.textContextScore,
    this.heartRate,
    this.totalSteps,
    this.vitalityScore,
    required this.createdAt,
    this.reasons,
    this.recordingAnalysis,
    this.recordingCurve,
    this.locationCity,
  });

  NewEntry copyWith({
    String? id,
    double? textContextScore,
    int? heartRate,
    int? totalSteps,
    int? vitalityScore,
    DateTime? createdAt,
    List<String>? reasons,
    String? recordingAnalysis,
    List<double>? recordingCurve,
    String? locationCity,
  }) {
    return NewEntry(
      id: id ?? this.id,
      textContextScore: textContextScore ?? this.textContextScore,
      heartRate: heartRate ?? this.heartRate,
      totalSteps: totalSteps ?? this.totalSteps,
      vitalityScore: vitalityScore ?? this.vitalityScore,
      createdAt: createdAt ?? this.createdAt,
      reasons: reasons ?? this.reasons,
      recordingAnalysis: recordingAnalysis ?? this.recordingAnalysis,
      recordingCurve: recordingCurve ?? this.recordingCurve,
      locationCity: locationCity ?? this.locationCity,
    );
  }
}