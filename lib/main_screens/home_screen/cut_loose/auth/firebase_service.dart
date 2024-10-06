import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getMessages() async {
    final snapshot = await _firestore.collection('cut_loose').get();
    return snapshot.docs.map((doc) => doc['message'] as String).toList();
  }

  Future<void> addMessage(String message) async {
    await _firestore.collection('cut_loose').add({'message': message});
  }
}
