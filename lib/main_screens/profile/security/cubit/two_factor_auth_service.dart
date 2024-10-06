import 'package:firebase_auth/firebase_auth.dart';
import 'package:otp/otp.dart';

class TwoFactorAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> enableGoogleAuthenticator() async {
    try {
      final String secret = OTP.randomSecret();
      final String otpAuthUri = 'otpauth://totp/freerave:${_auth.currentUser?.email}?secret=$secret&issuer=freerave';
      return otpAuthUri;  // Return the OTP Auth URI
    } catch (e) {
      throw Exception("Failed to enable Google Authenticator: $e");
    }
  }

  // Future<bool> verifyGoogleAuthCode(String code) async {
  //   try {
  //     // final String secret = // retrieve the secret for the user from your backend;
  //     final generatedCode = OTP.generateTOTPCodeString(secret, DateTime.now().millisecondsSinceEpoch);
  //     return generatedCode == code;
  //   } catch (e) {
  //     throw Exception("Failed to verify Google Authenticator code: $e");
  //   }
  // }

  Future<void> enableSMS(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception("Failed to send SMS: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          // Save the verificationId for later use
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      throw Exception("Failed to enable SMS 2FA: $e");
    }
  }

  Future<bool> verifySMSCode(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> enableEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw Exception("No user is signed in");
      }
    } catch (e) {
      throw Exception("Failed to enable email 2FA: $e");
    }
  }

  Future<bool> verifyEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      } else {
        throw Exception("No user is signed in");
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> disable2FA() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user is signed in");
      }

      // Unlink phone number
      if (user.phoneNumber != null) {
        await user.unlink(PhoneAuthProvider.PROVIDER_ID);
      }

      // Remove secret for Google Authenticator
      // This typically involves removing the secret from your backend or database
      // Example: await _removeGoogleAuthenticatorSecret(user.uid);

      // Optionally, reload the user to ensure changes are reflected
      await user.reload();
    } catch (e) {
      throw Exception("Failed to disable 2FA: $e");
    }
  }

  // Example method to remove Google Authenticator secret from your backend
  Future<void> _removeGoogleAuthenticatorSecret(String userId) async {
    // Implement your logic to remove the secret from your backend or database
  }
}
