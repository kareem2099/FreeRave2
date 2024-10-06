import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool passwordVisible;
  final VoidCallback onVisibilityToggle;

  const PasswordField({
    required this.controller,
    required this.labelText,
    required this.passwordVisible,
    required this.onVisibilityToggle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !passwordVisible,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(
            passwordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
    );
  }
}
