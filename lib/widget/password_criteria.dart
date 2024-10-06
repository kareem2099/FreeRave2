import 'package:flutter/material.dart';

class PasswordCriteria extends StatelessWidget {
  final bool isValid;
  final String label;

  const PasswordCriteria(
      {super.key, required this.isValid, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle,
          color: isValid ? Colors.green : Colors.grey,
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          label,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.grey,
            decoration: isValid ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
