import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../widget/custom_text_form_field.dart';
import '../../widget/social_button.dart';
import '../../utils/validators.dart';
import '../../widget/forgot_password_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home', (route) => false);
            } else if (state is AuthError) {
              Validators.handleNetworkError(context, state.message);
            }
          },
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextFormField(
                                controller: _emailController,
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                validator: Validators.validateEmail,
                              ),
                              const SizedBox(height: 16.0),
                              CustomTextFormField(
                                controller: _passwordController,
                                labelText: 'Password',
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(Icons.lock),
                                validator: Validators.validateLoginPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const ForgotPasswordDialog(),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    final email = _emailController.text;
                                    final password = _passwordController.text;
                                    context
                                        .read<AuthCubit>()
                                        .signInWithEmail(email, password);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SocialButton(
                                text: 'Sign in with Google',
                                icon: Icons.g_mobiledata,
                                color: Colors.red,
                                onPressed: () {
                                  context.read<AuthCubit>().signInWithGoogle();
                                },
                              ),
                              const SizedBox(height: 10),
                              SocialButton(
                                text: 'Sign in with Facebook',
                                icon: Icons.facebook,
                                color: Colors.blue,
                                onPressed: () {
                                  context
                                      .read<AuthCubit>()
                                      .signInWithFacebook();
                                },
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/register', (route) => false);
                                },
                                child: const Text(
                                  'Not in our family yet? Be with us!',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (state is AuthLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
