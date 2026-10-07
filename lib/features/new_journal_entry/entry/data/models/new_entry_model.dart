import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/new_entry.dart';

class NewEntryModel extends NewEntry {
  const NewEntryModel({
    super.id,
    super.textContextScore,
    super.heartRate,
    super.totalSteps,
    super.vitalityScore,
    required super.createdAt,
    super.reasons,
    super.recordingAnalysis,
    super.recordingCurve,
    super.locationCity,
  });

  factory NewEntryModel.fromEntity(NewEntry entry) {
    return NewEntryModel(
      id: entry.id,
      textContextScore: entry.textContextScore,
      heartRate: entry.heartRate,
      totalSteps: entry.totalSteps,
      vitalityScore: entry.vitalityScore,
      createdAt: entry.createdAt,
      reasons: entry.reasons,
      recordingAnalysis: entry.recordingAnalysis,
      recordingCurve: entry.recordingCurve,
      locationCity: entry.locationCity,
    );
  }

  factory NewEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;

    return NewEntryModel(
      id: doc.id,
      textContextScore: (d['textContextScore'] as num?)?.toDouble(),
      heartRate: d['heartRate'],
      totalSteps: d['totalSteps'],
      vitalityScore: d['vitalityScore'],
      reasons: List<String>.from(d['reasons'] ?? []),
      recordingAnalysis: d['recordingAnalysis'],
      recordingCurve: (d['recordingCurve'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      locationCity: d['locationCity'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'vitalityScore': vitalityScore,
      'textContextScore': textContextScore,
      'heartRate': heartRate,
      'totalSteps': totalSteps,
      'reasons': reasons ?? [],
      'recordingAnalysis': recordingAnalysis,
      'recordingCurve': recordingCurve,
      'locationCity': locationCity,
    };
  }
}