import '../entities/new_entry.dart';
import '../entities/entry_draft.dart';

abstract class EntryRepository {
  // Remote
  Future<String> saveEntry(NewEntry entry);
  Future<List<NewEntry>> getEntries();

  // Local draft
  Future<void> saveDraft(EntryDraft draft);
  Future<EntryDraft?> loadDraft();
  Future<void> clearDraft();
  Future<bool> hasDraft();
}