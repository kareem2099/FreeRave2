import 'package:flutter/material.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation for registration
  static String? validateRegistrationPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    List<String> errors = [];

    if (value.length < 8) {
      errors.add('Password must be at least 8 characters long');
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter');
    }
    if (!value.contains(RegExp(r'\d'))) {
      errors.add('Password must contain at least one number');
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Password must contain at least one special character');
    }

    if (errors.isNotEmpty) {
      return errors.join(', ');
    }

    return null; // If all conditions are met
  }

  // Password validation for login
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Your password is not correct';
    }
    return null; // Less strict validation for login
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateSmsCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the SMS code';
    }
    if (value.length != 6) {
      return 'Please enter a valid 6-digit code';
    }
    return null;
  }
  static String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the SMS code';
    }
    if (value.length != 6) {  // Assuming the SMS code is 6 digits
      return 'The code should be 6 digits long';
    }
    return null;
  }

  // Network error handling
  static void handleNetworkError(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(errorMessage)),
          ],
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
