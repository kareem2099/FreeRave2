import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/note_model.dart';
import 'note_service.dart';
import 'note_state.dart';


class NoteCubit extends Cubit<NoteState> {
  final NoteService _noteService;

  NoteCubit(this._noteService) : super(NotesInitial());

  NoteService get noteService => _noteService;

  void fetchNotes() {
    emit(NotesLoading());
    _noteService.getNotes().listen(
      (notes) {
        emit(NotesLoaded(notes));
      },
      onError: (error) {
        emit(NotesError('Failed to fetch notes: ${error.toString()}'));
      },
    );
  }

  Future<void> addNote(NoteModel note) async {
    try {
      await _noteService.addNote(note);
      emit(NoteAdded());
      fetchNotes();
    } catch (e) {
      emit(NotesError('Failed to add note: ${e.toString()}'));
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      await _noteService.updateNote(note);
      emit(NoteUpdated());
      fetchNotes();
    } catch (e) {
      emit(NotesError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _noteService.deleteNote(noteId);
      emit(NoteDeleted());
      fetchNotes();
    } catch (e) {
      emit(NotesError('Failed to delete note: ${e.toString()}'));
    }
  }

  void searchNotes(String query) {
    emit(NotesLoading());
    _noteService.searchNotes(query).listen(
      (notes) {
        emit(NotesLoaded(notes));
      },
      onError: (error) {
        emit(NotesError('Failed to search notes: ${error.toString()}'));
      },
    );
  }

  void filterNotesByDate(DateTime startDate, DateTime endDate) {
    emit(NotesLoading());
    _noteService.filterNotesByDate(startDate, endDate).listen(
      (notes) {
        emit(NotesLoaded(notes));
      },
      onError: (error) {
        emit(NotesError('Failed to filter notes by date: ${error.toString()}'));
      },
    );
  }

  void filterNotesByTag(String tag) {
    emit(NotesLoading());
    _noteService.filterNotesByTag(tag).listen(
      (notes) {
        emit(NotesLoaded(notes));
      },
      onError: (error) {
        emit(NotesError('Failed to filter notes by tag: ${error.toString()}'));
      },
    );
  }
  void pinNote(NoteModel note) async {
    try {
      final updatedNote = note.copyWith(priority: 1);
      await noteService.updateNote(updatedNote);
      fetchNotes();
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}
