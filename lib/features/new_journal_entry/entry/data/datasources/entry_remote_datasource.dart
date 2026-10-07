import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kora/features/new_journal_entry/entry/domain/entities/new_entry.dart';

import '../models/new_entry_model.dart';

class EntryRemoteDataSource {
  final FirebaseFirestore db;
  final FirebaseAuth auth;

  EntryRemoteDataSource({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : db = db ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  Future<String> saveEntry(NewEntry entry) async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw StateError('No user');
    }

    final doc = db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .doc();

    final model = NewEntryModel.fromEntity(entry);

    await doc.set(model.toMap());

    return doc.id;
  }

  Future<List<NewEntry>> getEntries() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) return [];

    final snapshot = await db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(NewEntryModel.fromFirestore)
        .toList();
  }
}