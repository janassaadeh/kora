import 'package:kora/features/new_journal_entry/entry/data/datasources/entry_local_datasource.dart';
import 'package:kora/features/new_journal_entry/entry/data/datasources/entry_remote_datasource.dart';

import '../../domain/entities/entry_draft.dart';
import '../../domain/entities/new_entry.dart';
import '../../domain/repositories/entry_repository.dart';


class EntryRepositoryImpl implements EntryRepository {
  final EntryLocalDataSource _local;
  final EntryRemoteDataSource _remote;

  const EntryRepositoryImpl({
    required EntryLocalDataSource local,
    required EntryRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  // ── Remote ─────────────────────────────────────────────────────────────────

  @override
  Future<String> saveEntry(NewEntry entry) => _remote.saveEntry(entry);

  @override
  Future<List<NewEntry>> getEntries() => _remote.getEntries();

  // ── Local draft ────────────────────────────────────────────────────────────

  @override
  Future<void> saveDraft(EntryDraft draft) => _local.saveDraft(draft);

  @override
  Future<EntryDraft?> loadDraft() => _local.loadDraft();

  @override
  Future<void> clearDraft() => _local.clearDraft();

  @override
  Future<bool> hasDraft() async => (await _local.loadDraft()) != null;
}