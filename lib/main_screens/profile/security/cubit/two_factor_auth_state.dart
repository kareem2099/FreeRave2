abstract class TwoFactorAuthState {}

// Initial state when 2FA is not yet started
class TwoFactorAuthInitial extends TwoFactorAuthState {
  final String qrCodeData;
  TwoFactorAuthInitial({required this.qrCodeData});
}

// State when 2FA process is loading
class TwoFactorAuthLoading extends TwoFactorAuthState {}

// State when QR code is generated
class TwoFactorAuthQRCodeGenerated extends TwoFactorAuthState {
  final String qrCodeData;
  TwoFactorAuthQRCodeGenerated({required this.qrCodeData});
}

// State when 2FA is successfully enabled
class TwoFactorAuthEnabled extends TwoFactorAuthState {}

// State when 2FA is successfully disabled
class TwoFactorAuthDisabled extends TwoFactorAuthState {}

// State when a verification code is sent to the user
class TwoFactorAuthCodeSent extends TwoFactorAuthState {}

// State when waiting for user to input the verification code
class TwoFactorAuthAwaitingCode extends TwoFactorAuthState {}

// State when the verification code is successfully verified
class TwoFactorAuthCodeVerified extends TwoFactorAuthState {}

// State when there is an error in the 2FA process
class TwoFactorAuthError extends TwoFactorAuthState {
  final String message;

  TwoFactorAuthError(this.message);
}

// State when there is an error specific to code verification
class TwoFactorAuthCodeError extends TwoFactorAuthState {
  final String message;

  TwoFactorAuthCodeError(this.message);
}
