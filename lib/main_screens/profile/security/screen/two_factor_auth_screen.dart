import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';


import '../cubit/two_factor_auth_cubit.dart';
import '../cubit/two_factor_auth_state.dart';
import 'code_verification_screen.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  TwoFactorAuthScreenState createState() => TwoFactorAuthScreenState();
}

class TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  String enteredCode = '';

  @override
  void initState() {
    super.initState();
    // Start the QR code timer when the screen is loaded
    context.read<TwoFactorAuthCubit>().enable2FA(method: 'google');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enable 2FA with Google Authenticator')),
      body: BlocConsumer<TwoFactorAuthCubit, TwoFactorAuthState>(
        listener: (context, state) {
          if (state is TwoFactorAuthEnabled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Google Authenticator 2FA Enabled')),
            );
            Navigator.of(context).pop(); // Navigate back or to a success screen
          } else if (state is TwoFactorAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TwoFactorAuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TwoFactorAuthInitial ||
              state is TwoFactorAuthQRCodeGenerated ||
              state is TwoFactorAuthCodeSent) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Scan this QR Code with Google Authenticator:'),
                  const SizedBox(height: 20),
                  if (state is TwoFactorAuthInitial ||
                      state is TwoFactorAuthQRCodeGenerated) ...[
                    QrImageView(
                      data: (state as dynamic).qrCodeData,
                      // Ensure qrCodeData is passed correctly
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context
                          .read<TwoFactorAuthCubit>()
                          .enable2FA(method: 'google'),
                      child: const Text('Enable Google Authenticator'),
                    ),
                  ],
                  if (state is TwoFactorAuthCodeSent) ...[
                    TextField(
                      decoration: const InputDecoration(
                          labelText: 'Enter the code from Google Authenticator',
                          labelStyle: TextStyle(color: Colors.pink)),
                      onChanged: (code) {
                        enteredCode = code;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const CodeVerificationScreen(),
                          ),
                        );
                      },
                      // onPressed: () => context.read<TwoFactorAuthCubit>().verifyCode(method: 'google', code: enteredCode),
                      child: const Text('Verify Code'),
                    ),
                  ],
                ],
              ),
            );
          } else if (state is TwoFactorAuthEnabled) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                      'Congratulations! You have activated 2FA security.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TwoFactorAuthCubit>().disable2FA(),
                    child: const Text('Disable 2FA'),
                  ),
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
