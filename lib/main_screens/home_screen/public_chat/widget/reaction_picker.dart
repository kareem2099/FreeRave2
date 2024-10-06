import 'package:flutter/material.dart';

Future<String?> showReactionPicker(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Reaction'),
        content: Wrap(
          children: [
            IconButton(
              icon: const Text('😀'),
              onPressed: () => Navigator.pop(context, 'smile'),
            ),
            IconButton(
              icon: const Text('😢'),
              onPressed: () => Navigator.pop(context, 'sad'),
            ),
            IconButton(
              icon: const Text('👍'),
              onPressed: () => Navigator.pop(context, 'thumbs_up'),
            ),
            IconButton(
              icon: const Text('❤️'),
              onPressed: () => Navigator.pop(context, 'heart'),
            ),
          ],
        ),
      );
    },
  );
}