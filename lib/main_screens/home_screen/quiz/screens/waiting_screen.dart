import 'package:flutter/material.dart';

class WaitingScreen extends StatelessWidget {
  final String message;
  final Widget? loadingIndicator;

  const WaitingScreen({Key? key, required this.message, this.loadingIndicator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loadingIndicator ?? const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
