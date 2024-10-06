import 'package:flutter/material.dart';
import 'single_player_screen.dart';
import 'two_player_screen.dart';

class HomeScreenQuiz extends StatelessWidget {
  const HomeScreenQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SinglePlayerScreen()),
                );
              },
              child: const Text('Single Player'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TwoPlayerScreen()),
                );
              },
              child: const Text('Two Players'),
            ),
          ],
        ),
      ),
    );
  }
}
