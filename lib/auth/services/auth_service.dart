import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get user => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Helper method to save user data in Firestore
  Future<void> _saveUserData(User user, Map<String, String?> userData) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userRef.set({
      'uid': user.uid,
      'name': userData['name'],
      'email': userData['email'],
      'photoUrl': userData['photoUrl'],
      'friendRequests': [],
      'friends': [],
      'passwordChangeDate': null,
      'passwordHistory': [],
    });
  }

  // Mock method to get a StreamChat token based on Firebase UID
  Future<String> getStreamChatToken(String userId) async {
    final url = Uri.parse(
        'https://freerave-o9upnehct-kareem-ehabs-projects-6a2c349e.vercel.app/token'); // Replace with your backend URL

    final response = await http.get(
      url.replace(queryParameters: {'userId': userId}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Print the response body for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token']; // The token you need to use for StreamChat

      // Print the token to ensure you're receiving it correctly
      print('Generated StreamChat token: $token');
      return token;
    } else {
      // Print the error details for debugging
      print(
          'Failed to get StreamChat token. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to generate StreamChat token');
    }
  }

  Map<String, String?> getUserInfo() {
    final user = currentUser;
    return {
      'userID': user?.uid,
      'name': user?.displayName,
      'email': user?.email,
      'photoUrl': user?.photoURL,
    };
  }

  Future<void> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    await _saveUserData(userCredential.user!, {
      'name': userCredential.user?.displayName,
      'email': userCredential.user?.email,
      'photoUrl': userCredential.user?.photoURL,
    });
  }

  Future<void> registerWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveUserData(userCredential.user!, {
      'name': userCredential.user?.displayName,
      'email': userCredential.user?.email,
      'photoUrl': userCredential.user?.photoURL,
    });
    await userCredential.user?.sendEmailVerification();
  }

  Future<Map<String, String?>> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);

    final user = userCredential.user;
    final userData = {
      'uid': user?.uid,
      'name': user?.displayName,
      'email': user?.email,
      'photoUrl': user?.photoURL,
    };
    // Save user data
    await _saveUserData(user!, userData);
    return userData;
  }

  Future<Map<String, String?>> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final OAuthCredential credential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
    final userCredential = await _auth.signInWithCredential(credential);

    final user = userCredential.user;

    final dataToSave = {
      'name': user?.displayName,
      'email': user?.email,
      'photoUrl': user?.photoURL,
    };
    // Save user data
    await _saveUserData(user!, dataToSave);
    return dataToSave;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }
}
