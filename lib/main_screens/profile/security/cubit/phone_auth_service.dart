import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithPhoneNumber(
      String phoneNumber, Function(String verificationId) codeSent) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically sign in the user if the verification is completed
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw PlatformException(
          code: e.code,
          message: e.message,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verification ID and show the code input field
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    await _auth.signInWithCredential(credential);
  }
}
