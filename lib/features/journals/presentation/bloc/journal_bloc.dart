import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/features/journals/presentation/bloc/journal_event.dart';
import 'package:kora/features/journals/presentation/bloc/journal_state.dart';
import 'package:kora/features/journals/data/entry_firestore_service.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/get_entries.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final GetEntries getEntries;

  JournalBloc(this.getEntries) : super(JournalInitial()) {
    on<LoadEntries>(_load);
    on<RefreshEntries>(_load);
  }

  Future<void> _load(
    JournalEvent event,
    Emitter<JournalState> emit,
  ) async {
    emit(JournalLoading());

    try {
      final entries = await getEntries();
      emit(JournalLoaded(entries));
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }
}