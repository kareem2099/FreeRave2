import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freerave/main_screens/profile/security/password/screen/reset_password_screen.dart';


import '../cubit/password_management_cubit.dart';
import '../cubit/password_management_state.dart';
import '../widget/password_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _repeatPasswordVisible = false;
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<PasswordManagementCubit>().checkPasswordExpiry();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: Colors.deepPurple,
      ),
      body: BlocConsumer<PasswordManagementCubit, PasswordManagementState>(
        listener: (context, state) {
          if (state is PasswordManagementSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PasswordManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PasswordManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          bool isEmailAuth = user?.providerData.any((info) => info.providerId == 'password') ?? false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (isEmailAuth) ...[
                  PasswordField(
                    controller: _oldPasswordController,
                    labelText: "Old Password",
                    passwordVisible: _oldPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _oldPasswordVisible = !_oldPasswordVisible;
                      });
                    },
                  ),
                  PasswordField(
                    controller: _newPasswordController,
                    labelText: "New Password",
                    passwordVisible: _newPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _newPasswordVisible = !_newPasswordVisible;
                      });
                    },
                  ),
                  FlutterPasswordStrength(
                    password: _newPasswordController.text,
                    strengthCallback: (strength) {
                      setState(() {
                        _passwordStrength = strength;
                      });
                    },
                  ),
                  PasswordField(
                    controller: _repeatPasswordController,
                    labelText: "Repeat New Password",
                    passwordVisible: _repeatPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _repeatPasswordVisible = !_repeatPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_newPasswordController.text.trim() != _repeatPasswordController.text.trim()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Passwords do not match")),
                        );
                      } else if (_newPasswordController.text.trim() == _oldPasswordController.text.trim()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("New password cannot be the same as the old password")),
                        );
                      } else if (_passwordStrength < 0.5) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password is too weak")),
                        );
                      } else {
                        context.read<PasswordManagementCubit>().changePassword(
                            _oldPasswordController.text.trim(),
                            _newPasswordController.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text("Change Password"),
                  ),
                ] else ...[
                  const Text(
                    "You signed in with Google or Facebook. Please reset your password.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text("Reset Password"),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
