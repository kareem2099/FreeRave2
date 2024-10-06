import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/password_management_cubit.dart';
import '../cubit/password_management_state.dart';

class ResetPasswordScreen extends StatefulWidget {

  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  void _showEmailSentDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Email Sent"),
        content: Text("A password reset link has been sent to $email."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: BlocConsumer<PasswordManagementCubit, PasswordManagementState>(
        listener: (context, state) {
          if (state is PasswordManagementSuccess) {
            _showEmailSentDialog(context, _emailController.text.trim());
          } else if (state is PasswordManagementError) {
            String errorMessage;
            switch (state.errorCode) {
              case 'user-not-found':
                errorMessage = "No account found with this email.";
                break;
              case 'network-request-failed':
                errorMessage = "Network error. Please try again.";
                break;
              default:
                errorMessage = "An unexpected error occurred. Please try again.";
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        },
        builder: (context, state) {
          if (state is PasswordManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your registered email",
                    ),
                    validator: (value) => validateEmail(value ?? ''),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: state is PasswordManagementLoading
                        ? null
                        : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<PasswordManagementCubit>().resetPassword(
                            _emailController.text.trim());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a valid email address")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text("Reset Password"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
