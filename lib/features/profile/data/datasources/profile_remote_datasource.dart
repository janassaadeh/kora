import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kora/features/auth/data/models/user_model.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore db;
  final FirebaseAuth auth;

  ProfileRemoteDataSource({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : db = db ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  Future<UserModel> getProfile() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('No user');

    final doc = await db.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      final firebaseUser = auth.currentUser!;
      final model = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
      );
      await db.collection('users').doc(uid).set(model.toJson());
      return model;
    }

    return UserModel.fromJson(doc.data()!);
  }

  Future<String> uploadProfilePhoto(File file) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('No user');

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    await db.collection('users').doc(uid).update({'photoUrl': base64Image});

    return base64Image;
  }

  Future<({int streak, int entryCount, double? vitalityScore})> getProfileStats() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('No user');

    final snapshot = await db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .orderBy('createdAt', descending: true)
        .get();

    final entryCount = snapshot.docs.length;
    if (entryCount == 0) return (streak: 0, entryCount: 0, vitalityScore: null);

    // Most recent entry vitality score
    final latestData = snapshot.docs.first.data();
    final vitalityScore = (latestData['vitalityScore'] as num?)?.toDouble();

    // Streak calculation
    final Set<String> datesWithEntry = {};
    for (final doc in snapshot.docs) {
      final raw = doc.data()['createdAt'];
      DateTime? dt;
      if (raw is Timestamp) {
        dt = raw.toDate().toLocal();
      } else if (raw is String) {
        dt = DateTime.tryParse(raw)?.toLocal();
      }
      if (dt != null) {
        datesWithEntry.add('${dt.year}-${dt.month}-${dt.day}');
      }
    }

    final now = DateTime.now();
    DateTime cursor = DateTime(now.year, now.month, now.day);

    if (!datesWithEntry.contains('${cursor.year}-${cursor.month}-${cursor.day}')) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    int streak = 0;
    while (datesWithEntry.contains('${cursor.year}-${cursor.month}-${cursor.day}')) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return (streak: streak, entryCount: entryCount, vitalityScore: vitalityScore);
  }
}