import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/cubit/auth_cubit.dart';
import '../../home_screen/connections/models/user_model.dart';
import '../security/screen/security_screen.dart';


class ProfileDetails extends StatelessWidget {
  final UserModel user;

  const ProfileDetails({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  user.photoUrl.isNotEmpty
                      ? user.photoUrl
                      : 'assets/images/default_profile_picture.png',
                ),
                onBackgroundImageError: (_, __) {
                  // print('Failed to load profile image, using default.');
                },
              ),
            ),
            const SizedBox(height: 16),

            // Name with animation
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            // Email with animation
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                user.email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),

            // Edit profile button with animation
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement profile editing screen or dialog
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
            const SizedBox(height: 32),

            // Additional features
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Security'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SecurityScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Recent Activity'),
              onTap: () {
                // TODO: Navigate to recent activity
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                final confirm = await _showConfirmationDialog(
                    context, 'Are you sure you want to sign out?');
                if (confirm && context.mounted) {
                 _signOut(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Delete Account'),
              onTap: () async {
                final confirm = await _showConfirmationDialog(context,
                    'Are you sure you want to delete your account? This action cannot be undone.');
                if (confirm) {
                  // TODO: Implement account deletion
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _signOut (BuildContext context) {
    context.read<AuthCubit>().signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}


