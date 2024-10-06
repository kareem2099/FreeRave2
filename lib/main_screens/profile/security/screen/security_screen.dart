import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freerave/main_screens/profile/security/cubit/two_factor_auth_cubit.dart';
import 'package:freerave/main_screens/profile/security/screen/sms_screen.dart';
import 'package:freerave/main_screens/profile/security/screen/two_factor_auth_screen.dart';

import '../cubit/two_factor_auth_state.dart';
import '../password/screen/change_password_screen.dart';
import '../password/screen/password_history_screen.dart';
import '../password/screen/reset_password_screen.dart';
import 'email_screen.dart';


class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Two-Factor Authentication (2FA)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Google Authenticator 2FA
            BlocBuilder<TwoFactorAuthCubit, TwoFactorAuthState>(
              builder: (context, state) {
                bool isGoogleAuthEnabled = false;
                if (state is TwoFactorAuthEnabled) {
                  isGoogleAuthEnabled = true;
                }

                return ListTile(
                  leading: Icon(Icons.security,
                      color: isGoogleAuthEnabled ? Colors.green : null),
                  title: const Text('Google Authenticator'),
                  subtitle:
                      const Text('Enable 2FA using Google Authenticator.'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TwoFactorAuthScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(),

            // SMS-based 2FA
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('SMS Authentication'),
              subtitle: const Text('Enable 2FA using SMS code.'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SmsScreen()),
                );
              },
            ),
            const Divider(),

            // Email-based 2FA
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Authentication'),
              subtitle: const Text('Enable 2FA using email code.'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EmailScreen()),
                );
              },
            ),
            const SizedBox(height: 32),

            const Text(
              'Password Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Change Password
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              subtitle:
                  const Text('Update your password and ensure it\'s strong.'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            const Divider(),

            // Password Reset
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Password Reset'),
              subtitle:
                  const Text('Reset your password securely via email or SMS.'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ResetPasswordScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // Password History
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Password History'),
              subtitle:
                  const Text('View your password history to avoid reuse.'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PasswordHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
