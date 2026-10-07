import '../entities/new_entry.dart';
import '../repositories/entry_repository.dart';

class GetEntries {
  final EntryRepository repository;

  GetEntries(this.repository);

  Future<List<NewEntry>> call() {
    return repository.getEntries();
  }
}