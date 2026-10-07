import 'package:kora/features/new_journal_entry/entry/domain/entities/new_entry.dart';

abstract class JournalState {}

class JournalInitial extends JournalState {}

class JournalLoading extends JournalState {}

class JournalLoaded extends JournalState {
  final List<NewEntry> entries;

  JournalLoaded(this.entries);
}

class JournalError extends JournalState {
  final String message;

  JournalError(this.message);
}