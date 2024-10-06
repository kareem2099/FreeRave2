import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/validators.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text;
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'If an account exists for this email, a password reset link has been sent.'),
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;

        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          _showEmailNotFoundDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send password reset email: $e'),
            ),
          );
        }
      }
    }
  }



  void _showEmailNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Not Registered'),
        content: const Text(
            'This email is not registered. Would you like to register?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/register');
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Enter your email',
            prefixIcon: Icon(Icons.email),
          ),
          validator: Validators.validateEmail,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _sendPasswordResetEmail,
          child: const Text('Send'),
        ),
      ],
    );
  }
}
