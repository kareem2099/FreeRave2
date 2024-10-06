import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/two_factor_auth_cubit.dart';
import '../cubit/two_factor_auth_service.dart';
import '../cubit/two_factor_auth_state.dart';

class TwoFactorAuthScreen extends StatelessWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TwoFactorAuthCubit(TwoFactorAuthService()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Two-Factor Authentication'),
        ),
        body: BlocConsumer<TwoFactorAuthCubit, TwoFactorAuthState>(
          listener: (context, state) {
            if (state is TwoFactorAuthEnabled) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('2FA Enabled'),
              ));
            } else if (state is TwoFactorAuthDisabled) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('2FA Disabled'),
              ));
            } else if (state is TwoFactorAuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: ${state.message}'),
              ));
            }
          },
          builder: (context, state) {
            if (state is TwoFactorAuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a method to enable Two-Factor Authentication (2FA):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Google Authenticator'),
                    onTap: () => context.read<TwoFactorAuthCubit>().enable2FA(method: 'google'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.sms),
                    title: const Text('SMS Authentication'),
                    onTap: () => _showPhoneNumberDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email Authentication'),
                    onTap: () => context.read<TwoFactorAuthCubit>().enable2FA(method: 'email'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TwoFactorAuthCubit>().disable2FA(),
                    child: const Text('Disable 2FA'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPhoneNumberDialog(BuildContext context) {
    final TextEditingController phoneNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Phone Number'),
          content: TextField(
            controller: phoneNumberController,
            decoration: const InputDecoration(hintText: 'Phone Number'),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final phoneNumber = phoneNumberController.text.trim();
                context.read<TwoFactorAuthCubit>().enable2FA(method: 'sms', phoneNumber: phoneNumber);
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
