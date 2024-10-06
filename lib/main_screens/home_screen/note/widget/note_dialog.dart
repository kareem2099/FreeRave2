import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/note_cubit.dart';
import '../model/note_model.dart';

class NoteDialog extends StatelessWidget {
  final NoteCubit notesCubit;
  final NoteModel? note;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController tagsController = TextEditingController();

  NoteDialog({
    super.key,
    required this.notesCubit,
    this.note,
    required this.titleController,
    required this.contentController,
  }) {
    if (note != null) {
      tagsController.text = note!.tags.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(note == null ? 'Add New Note' : 'Edit Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(hintText: 'Content'),
              maxLines: 5,
            ),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(hintText: 'Tags (comma separated)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (titleController.text.isEmpty || contentController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Title and Content cannot be empty')),
              );
              return;
            }
            final tags = tagsController.text.split(',').map((tag) => tag.trim()).toList();
            final newNote = NoteModel(
              id: note?.id ?? '',
              title: titleController.text,
              content: contentController.text,
              timestamp: Timestamp.now(),
              userId: notesCubit.noteService.auth.currentUser!.uid,
              tags: tags,
              priority: note?.priority ?? 0,
            );
            if (note == null) {
              notesCubit.addNote(newNote);
            } else {
              notesCubit.updateNote(newNote);
            }
            Navigator.pop(context);
          },
          child: Text(note == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
