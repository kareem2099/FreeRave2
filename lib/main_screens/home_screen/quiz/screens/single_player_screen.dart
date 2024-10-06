import 'package:flutter/material.dart';
import 'question_creation_screen.dart';
import 'waiting_screen.dart';

class SinglePlayerScreen extends StatelessWidget {
  const SinglePlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Player Mode'),
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
              child: const Text('Put Questions'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WaitingScreen(message: 'Please wait while the questions are being prepared...')),
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
