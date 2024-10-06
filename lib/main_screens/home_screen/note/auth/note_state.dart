import '../model/note_model.dart';

abstract class NoteState {}

class NotesInitial extends NoteState {}

class NotesLoading extends NoteState {}

class NotesLoaded extends NoteState {
  final List<NoteModel> notes;

  NotesLoaded(this.notes);
}

class NoteAdded extends NoteState {}

class NoteUpdated extends NoteState {}

class NoteDeleted extends NoteState {}

class NotesError extends NoteState {
  final String message;

  NotesError(this.message);
}