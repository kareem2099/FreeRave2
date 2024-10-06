import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/password_management_state.dart';

class PasswordManagementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );

        // Re-authenticate the user
        await user.reauthenticateWithCredential(credential);

        // Update the password
        await user.updatePassword(newPassword);

        // Save the new password and update the password change date
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'passwordHistory': FieldValue.arrayUnion([
            {
              'password': hashPassword(newPassword), // Consider hashing the password
              'changeDate': FieldValue.serverTimestamp(),
              'strength': calculatePasswordStrength(newPassword),
            }
          ]),
          'passwordChangeDate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Handle potential errors
      throw Exception('Password change failed: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Handle potential errors
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<List<PasswordHistoryEntry>> getPasswordHistory() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          List<PasswordHistoryEntry> historyData =
          (doc['passwordHistory'] as List<dynamic>).map((entry) {
            return PasswordHistoryEntry(
              password: entry['password'] as String,
              changeDate: (entry['changeDate'] as Timestamp).toDate(),
              strength: entry['strength'] as double,
            );
          }).toList();
          return historyData;
        }
      }
    } catch (e) {
      // Handle potential errors
      throw Exception('Failed to retrieve password history: $e');
    }
    return [];
  }

  Future<DateTime?> getPasswordChangeDate() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

          if (data != null && data.containsKey('passwordChangeDate')) {
            Timestamp? timestamp = data['passwordChangeDate'];
            return timestamp?.toDate();
          }
        }
      }
    } catch (e) {
      // Handle potential errors
      throw Exception('Failed to retrieve password change date: $e');
    }
    return null;
  }

  double calculatePasswordStrength(String password) {
    double strength = 0;

    // Check length
    if (password.length >= 8) {
      strength += 0.25;
      if (password.length >= 12) {
        strength += 0.25;
      }
    }

    // Check for uppercase letters
    if (password.contains(RegExp(r'[A-Z]'))) {
      strength += 0.25;
    }

    // Check for lowercase letters
    if (password.contains(RegExp(r'[a-z]'))) {
      strength += 0.25;
    }

    // Check for numbers
    if (password.contains(RegExp(r'[0-9]'))) {
      strength += 0.25;
    }

    // Check for special characters
    if (password.contains(RegExp(r'[!@#\$&*~%^]'))) {
      strength += 0.25;
    }

    // Penalize for sequential characters (e.g., "123", "abc")
    if (RegExp(
        r'(012|123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)')
        .hasMatch(password)) {
      strength -= 0.25;
    }

    // Penalize for repeated characters (e.g., "aaa", "111")
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      strength -= 0.25;
    }

    // Ensure strength is within the range 0.0 to 1.0
    return strength.clamp(0.0, 1.0);
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
