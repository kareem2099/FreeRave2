import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freerave/main_screens/profile/security/password/cubit/password_management_state.dart';

import '../services/password_management_service.dart';

class PasswordManagementCubit extends Cubit<PasswordManagementState> {
  final PasswordManagementService _passwordService;

  PasswordManagementCubit(this._passwordService) : super(PasswordManagementInitial());

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      emit(PasswordManagementLoading());
      await _passwordService.changePassword(oldPassword, newPassword);
      emit(PasswordManagementSuccess("Password changed successfully"));
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific exceptions
      emit(PasswordManagementError(_getErrorMessage(e)));
    } catch (e) {
      emit(PasswordManagementError(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      emit(PasswordManagementLoading());
      await _passwordService.sendPasswordResetEmail(email);
      emit(PasswordManagementSuccess("Password reset email sent"));
    } catch (e) {
      emit(PasswordManagementError(e.toString()));
    }
  }

  Future<void> fetchPasswordHistory() async {
    try {
      emit(PasswordManagementLoading());
      final history = await _passwordService.getPasswordHistory();
      emit(PasswordHistoryLoaded(history));
    } catch (e) {
      emit(PasswordManagementError(e.toString()));
    }
  }

  Future<void> checkPasswordExpiry() async {
    try {
      emit(PasswordManagementLoading());
      final changeDate = await _passwordService.getPasswordChangeDate();
      if (changeDate != null) {
        final expiryDate = changeDate.add(const Duration(days: 90)); // Example: 90 days expiry
        if (DateTime.now().isAfter(expiryDate.subtract(const Duration(days: 7)))) {
          emit(PasswordExpiryWarning("Your password will expire soon. Please change it."));
        } else {
          emit(PasswordExpiryChecked("Your password is still valid.",expiryDate));
        }
      } else {
        emit(PasswordManagementError("Password change date not found."));
      }
    } catch (e) {
      emit(PasswordManagementError(e.toString()));
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return "The old password is incorrect. Please try again.";
      case 'weak-password':
        return "The new password is too weak. Please choose a stronger password.";
      case 'network-request-failed':
        return "Network error. Please check your internet connection and try again.";
      default:
        return "An error occurred. Please try again.";
    }
  }
}
