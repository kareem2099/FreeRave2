import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../home_screen/connections/models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> getUserProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('User is not logged in');
      }
      final doc = await _firestore.collection('users').doc(uid).get();
      return UserModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to load user profile: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }
}
