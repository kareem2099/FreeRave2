import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../main_screens/profile/security/cubit/phone_number_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../utils/validators.dart';
import '../../widget/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialCharacter = false;
  bool _hasMinLength = false;
  final bool _obscurePassword = true;
  bool _isUsingPhoneNumber = false;
  bool _isCodeSent = false;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');

  void _checkPassword(String value) {
    setState(() {
      _hasUpperCase = value.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = value.contains(RegExp(r'[a-z]'));
      _hasNumber = value.contains(RegExp(r'\d'));
      _hasSpecialCharacter = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = value.length >= 8;
    });
  }

  void _toggleUsePhoneNumber(bool value) {
    setState(() {
      _isUsingPhoneNumber = value;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify Your Email'),
          content: const Text(
              'A verification link has been sent to your email. Please verify your email before logging in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final phone = _phoneNumber.phoneNumber ?? '';

      if (_isUsingPhoneNumber) {
        context.read<PhoneNumberCubit>().signInWithPhoneNumber(phone);
      } else {
        context.read<AuthCubit>().registerWithEmail(email, password);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthRegistrationSuccess) {
              Future.delayed(const Duration(milliseconds: 300), () {
                _showVerificationDialog();
              });
            } else if (state is AuthAuthenticated) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            } else if (state is AuthEmailNotVerified) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please verify your email before logging in.'),
                ),
              );
            } else if (state is AuthCodeSent) {
              setState(() {
                _isCodeSent = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SMS code sent. Please enter the code.'),
                ),
              );
            } else if (state is AuthError) {
              Validators.handleNetworkError(context, state.message);
            }
          },
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RegisterForm(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  phoneController: _phoneController,
                  smsCodeController: _smsCodeController,
                  obscurePassword: _obscurePassword,
                  hasUpperCase: _hasUpperCase,
                  hasLowerCase: _hasLowerCase,
                  hasNumber: _hasNumber,
                  hasSpecialCharacter: _hasSpecialCharacter,
                  hasMinLength: _hasMinLength,
                  isUsingPhoneNumber: _isUsingPhoneNumber,
                  isCodeSent: _isCodeSent,
                  onPasswordChanged: _checkPassword,
                  onToggleUsePhoneNumber: _toggleUsePhoneNumber,
                  onRegister: _register,
                  onPhoneNumberChanged: (PhoneNumber phoneNumber) {
                    setState(() {
                      _phoneNumber = phoneNumber;
                    });
                  },
                  onSendCode: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      context.read<PhoneNumberCubit>().signInWithPhoneNumber(_phoneController.text);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
