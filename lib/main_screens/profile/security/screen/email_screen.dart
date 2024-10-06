import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/two_factor_auth_cubit.dart';
import '../cubit/two_factor_auth_state.dart';


class EmailScreen extends StatelessWidget {
  const EmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String enteredCode = ''; // Local variable to capture user input

    return  Scaffold(
        appBar: AppBar(title: const Text('Enable Email 2FA')),
        body: BlocConsumer<TwoFactorAuthCubit, TwoFactorAuthState>(
          listener: (context, state) {
            if (state is TwoFactorAuthEnabled) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email 2FA Enabled')));
            } else if (state is TwoFactorAuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is TwoFactorAuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TwoFactorAuthInitial || state is TwoFactorAuthCodeSent) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (state is TwoFactorAuthInitial) ...[
                      ElevatedButton(
                        onPressed: () => context.read<TwoFactorAuthCubit>().enable2FA(method: 'email'),
                        child: const Text('Send Verification Email'),
                      ),
                    ],
                    if (state is TwoFactorAuthCodeSent) ...[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Enter the code sent to your email'),
                        onChanged: (code) {
                          enteredCode = code;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.read<TwoFactorAuthCubit>().verifyCode(method: 'email', code: enteredCode),
                        child: const Text('Verify Code'),
                      ),
                    ],
                  ],
                ),
              );
            } else {
              return const Center(child: Text('An error occurred.'));
            }
          },
        ),

    );
  }
}
