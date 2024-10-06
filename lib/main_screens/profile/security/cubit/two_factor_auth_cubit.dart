import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freerave/main_screens/profile/security/cubit/two_factor_auth_service.dart';
import 'package:freerave/main_screens/profile/security/cubit/two_factor_auth_state.dart';

import '../model/two_factor_auth_model.dart';


class TwoFactorAuthCubit extends Cubit<TwoFactorAuthState> {
  final TwoFactorAuthService _authService;
  Timer? _qrCodeTimer;

  TwoFactorAuthModel _authModel = TwoFactorAuthModel(method: '', isEnabled: false);

  TwoFactorAuthCubit(this._authService) : super(TwoFactorAuthInitial(qrCodeData: ''));

  Future<void> enable2FA({required String method, String? phoneNumber}) async {
    try {
      emit(TwoFactorAuthLoading());
      switch (method) {
        case 'google':
          final qrCodeData = await _authService.enableGoogleAuthenticator();
          _authModel = _authModel.copyWith(method: 'google', isEnabled: true);
          emit(TwoFactorAuthQRCodeGenerated(qrCodeData: qrCodeData));
          _startQRCodeTimer();
          break;
        case 'sms':
          if (phoneNumber == null) {
            throw Exception('Phone number is required for SMS 2FA');
          }
          await _authService.enableSMS(phoneNumber);
          _authModel = _authModel.copyWith(method: 'sms', isEnabled: true);
          emit(TwoFactorAuthCodeSent());
          break;
        case 'email':
          await _authService.enableEmail();
          _authModel = _authModel.copyWith(method: 'email', isEnabled: true);
          emit(TwoFactorAuthCodeSent());
          break;
        default:
          throw Exception('Invalid 2FA method');
      }
    } catch (e) {
      print('Error enabling $method 2FA: $e'); // Log the error
      emit(TwoFactorAuthError('Failed to enable $method 2FA: ${e.toString()}'));
    }
  }

  Future<void> verifyCode({required String method, required String code, String? verificationId}) async {
    try {
      emit(TwoFactorAuthLoading());
      bool isVerified = false;
      switch (method) {
        case 'sms':
          if (verificationId == null) {
            throw Exception('Verification ID is required for SMS code verification');
          }
          isVerified = await _authService.verifySMSCode(verificationId, code);
          break;
        case 'email':
          isVerified = await _authService.verifyEmail();
          break;
        default:
          throw Exception('Invalid 2FA method');
      }
      if (isVerified) {
        emit(TwoFactorAuthEnabled());
      } else {
        emit(TwoFactorAuthError('Invalid verification code'));
      }
    } catch (e) {
      print('Error verifying $method code: $e'); // Log the error
      emit(TwoFactorAuthError('Failed to verify $method code: ${e.toString()}'));
    }
  }

  Future<void> disable2FA() async {
    try {
      emit(TwoFactorAuthLoading());
      await _authService.disable2FA();
      _qrCodeTimer?.cancel();
      _authModel = _authModel.copyWith(isEnabled: false);
      emit(TwoFactorAuthDisabled());
    } catch (e) {
      print('Error disabling 2FA: $e'); // Log the error
      emit(TwoFactorAuthError('Failed to disable 2FA: ${e.toString()}'));
    }
  }

  void _startQRCodeTimer() {
    _qrCodeTimer?.cancel();
    _qrCodeTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final qrCodeData = await _authService.enableGoogleAuthenticator();
        emit(TwoFactorAuthQRCodeGenerated(qrCodeData: qrCodeData));
      } catch (e) {
        print('Error generating QR code: $e'); // Log the error
        emit(TwoFactorAuthError('Failed to generate QR code: ${e.toString()}'));
      }
    });
  }

  @override
  Future<void> close() {
    _qrCodeTimer?.cancel();
    return super.close();
  }
}
