import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/note_model.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuth get auth => _auth;

  CollectionReference get _notesCollection {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('notes');
  }

  Future<void> addNote(NoteModel note) async {
    try {
      await _notesCollection.add(note.toMap());
    } catch (e) {
      throw Exception('Failed to add note: ${e.toString()}');
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      await _notesCollection.doc(note.id).update(note.toMap());
    } catch (e) {
      throw Exception('Failed to update note: ${e.toString()}');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _notesCollection.doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: ${e.toString()}');
    }
  }

  Stream<List<NoteModel>> getNotes() {
    return _notesCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromDocument(doc)).toList();
    });
  }

  Stream<List<NoteModel>> searchNotes(String query) {
    return _notesCollection
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromDocument(doc)).toList();
    });
  }

  Stream<List<NoteModel>> filterNotesByDate(DateTime startDate, DateTime endDate) {
    return _notesCollection
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromDocument(doc)).toList();
    });
  }

  Stream<List<NoteModel>> filterNotesByTag(String tag) {
    return _notesCollection
        .where('tags', arrayContains: tag)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromDocument(doc)).toList();
    });
  }
}
