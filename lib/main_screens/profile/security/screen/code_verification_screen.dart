import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/two_factor_auth_cubit.dart';

class CodeVerificationScreen extends StatefulWidget {
  const CodeVerificationScreen({Key? key}) : super(key: key);

  @override
  CodeVerificationScreenState createState() => CodeVerificationScreenState();
}

class CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter 2FA Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Enter Code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final enteredCode = _codeController.text;
                context.read<TwoFactorAuthCubit>().verifyCode(method: 'google', code: enteredCode);
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
