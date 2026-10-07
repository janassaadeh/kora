import '../entities/new_entry.dart';
import '../repositories/entry_repository.dart';

class SaveEntryUseCase {
  final EntryRepository _repository;

  const SaveEntryUseCase(this._repository);

  Future<String> call(NewEntry entry) => _repository.saveEntry(entry);
}