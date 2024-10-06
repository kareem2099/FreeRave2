import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freerave/auth/cubit/auth_state.dart';
import 'package:freerave/main_screens/profile/security/cubit/phone_auth_service.dart';

class PhoneNumberCubit extends Cubit<AuthState> {
  final PhoneAuthService _authService;

  PhoneNumberCubit(this._authService) : super(AuthInitial());

  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    try {
      emit(AuthLoading());
      await _authService.signInWithPhoneNumber(phoneNumber, (verificationId) {
        emit(AuthCodeSent(verificationId));
      });
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    try {
      emit(AuthLoading());
      await _authService.verifySmsCode(verificationId, smsCode);
      emit(AuthAuthenticated(_authService.currentUser!, {}));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resendVerificationCode(String phoneNumber) async {
    try {
      emit(AuthLoading());
      await _authService.signInWithPhoneNumber(phoneNumber, (verificationId) {
        emit(AuthCodeSent(verificationId));
      });
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      final user = _authService.currentUser;
      await user?.reload();
      final isVerified = user?.emailVerified ?? false;
      if (isVerified) {
        emit(AuthAuthenticated(user!, {}));
      } else {
        emit(AuthEmailNotVerified());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
