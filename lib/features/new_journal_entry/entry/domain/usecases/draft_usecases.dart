import '../entities/entry_draft.dart';
import '../repositories/entry_repository.dart';

class SaveDraftUseCase {
  final EntryRepository _repository;
  const SaveDraftUseCase(this._repository);
  Future<void> call(EntryDraft draft) => _repository.saveDraft(draft);
}

class LoadDraftUseCase {
  final EntryRepository _repository;
  const LoadDraftUseCase(this._repository);
  Future<EntryDraft?> call() => _repository.loadDraft();
}

class ClearDraftUseCase {
  final EntryRepository _repository;
  const ClearDraftUseCase(this._repository);
  Future<void> call() => _repository.clearDraft();
}

class HasDraftUseCase {
  final EntryRepository _repository;
  const HasDraftUseCase(this._repository);
  Future<bool> call() => _repository.hasDraft();
}