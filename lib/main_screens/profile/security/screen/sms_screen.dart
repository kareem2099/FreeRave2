import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freerave/auth/cubit/auth_state.dart';

import '../cubit/phone_number_cubit.dart';

class SmsScreen extends StatelessWidget {
  const SmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String enteredPhoneNumber = '';
    String enteredCode = '';

    return  Scaffold(
        appBar: AppBar(title: const Text('Enable SMS 2FA')),
        body: BlocConsumer<PhoneNumberCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SMS 2FA Enabled')));
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AuthInitial || state is AuthCodeSent) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (state is AuthInitial) ...[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Enter your phone number'),
                        keyboardType: TextInputType.phone,
                        onChanged: (phone) {
                          enteredPhoneNumber = phone;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.read<PhoneNumberCubit>().signInWithPhoneNumber(enteredPhoneNumber),
                        child: const Text('Send Verification Code'),
                      ),
                    ],
                    if (state is AuthCodeSent) ...[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Enter the code sent to your phone'),
                        onChanged: (code) {
                          enteredCode = code;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.read<PhoneNumberCubit>().verifySmsCode(state.verificationId, enteredCode),
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
