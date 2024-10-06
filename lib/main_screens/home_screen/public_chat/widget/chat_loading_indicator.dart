import 'package:flutter/material.dart';

class ChatLoadingIndicator extends StatelessWidget {
  const ChatLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
      ),
    );
  }
}
