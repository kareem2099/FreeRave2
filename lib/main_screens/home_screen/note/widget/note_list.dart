import 'package:flutter/material.dart';
import '../auth/note_cubit.dart';
import '../model/note_model.dart';

class NoteList extends StatelessWidget {
  final List<NoteModel> notes;
  final NoteCubit notesCubit;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final Function(NoteModel?) showNoteDialog;

  const NoteList({super.key,
    required this.notes,
    required this.notesCubit,
    required this.titleController,
    required this.contentController,
    required this.showNoteDialog,
  });

  @override
  Widget build(BuildContext context) {
    // Sort notes to move loved notes to the top
    final sortedNotes = List<NoteModel>.from(notes)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return ListView.builder(
      itemCount: sortedNotes.length,
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        return Dismissible(
          key: Key(note.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.remove, color: Colors.white),
                SizedBox(width: 8),
                Text('Remove', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          secondaryBackground: Container(
            color: Colors.pink,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.favorite, color: Colors.white),
                SizedBox(width: 8),
                Text('Love', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Mark as loved
              notesCubit.pinNote(note);
              return false; // Prevent actual dismissal
            } else if (direction == DismissDirection.startToEnd) {
              // Confirm delete
              final bool? result = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Note'),
                  content: const Text('Are you sure you want to delete this note?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              return result ?? false;
            }
            return false;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              notesCubit.deleteNote(note.id);
            }
          },
          child: ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () {
              titleController.text = note.title;
              contentController.text = note.content;
              showNoteDialog(note);
            },
            trailing: note.priority == 1
                ? const Icon(Icons.favorite, color: Colors.pink)
                : null,
          ),
        );
      },
    );
  }
}
