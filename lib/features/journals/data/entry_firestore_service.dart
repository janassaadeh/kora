import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kora/features/new_journal_entry/entry/domain/entities/new_entry.dart';

class EntryFirestoreService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  EntryFirestoreService({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<String> saveEntry(NewEntry entry) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No user');

    final doc = _db.collection('users').doc(uid).collection('entries').doc();

    await doc.set(_toMap(entry));
    return doc.id;
  }

  Future<List<NewEntry>> getEntries() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final d = doc.data();

      return NewEntry(
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
    }).toList();
  }

  Map<String, dynamic> _toMap(NewEntry e) => {
        'createdAt': Timestamp.fromDate(e.createdAt),
        'vitalityScore': e.vitalityScore,
        'textContextScore': e.textContextScore,
        'heartRate': e.heartRate,
        'totalSteps': e.totalSteps,
        'reasons': e.reasons ?? [],
        'recordingAnalysis': e.recordingAnalysis,
        'recordingCurve': e.recordingCurve,
        'locationCity': e.locationCity,
      };
}