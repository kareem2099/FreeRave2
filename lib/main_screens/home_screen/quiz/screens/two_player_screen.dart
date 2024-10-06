import 'package:flutter/material.dart';
import 'question_creation_screen.dart';
import 'waiting_screen.dart';

class TwoPlayerScreen extends StatelessWidget {
  const TwoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Players Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuestionCreationScreen()),
                );
              },
              child: const Text('Create Questions'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WaitingScreen(message: 'Waiting for the other player to finish...')),
                );
              },
              child: const Text('Answer Questions'),
            ),
          ],
        ),
      ),
    );
  }
}
