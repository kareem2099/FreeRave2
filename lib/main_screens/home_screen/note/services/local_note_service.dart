import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/note_model.dart';

class LocalNoteService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT, content TEXT, timestamp INTEGER, userId TEXT, tags TEXT, attachments TEXT, priority INTEGER)",
        );
      },
      version: 1,
    );
  }

  Future<void> addNoteLocal(NoteModel note) async {
    final db = await database;
    try {
      await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Failed to add note: ${e.toString()}');
    }
  }

  Future<void> updateNoteLocal(NoteModel note) async {
    final db = await database;
    try {
      await db.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } catch (e) {
      throw Exception('Failed to update note: ${e.toString()}');
    }
  }

  Future<void> deleteNoteLocal(String noteId) async {
    final db = await database;
    try {
      await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [noteId],
      );
    } catch (e) {
      throw Exception('Failed to delete note: ${e.toString()}');
    }
  }

  Future<List<NoteModel>> getNotesLocal() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('notes');
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to fetch notes: ${e.toString()}');
    }
  }
}
