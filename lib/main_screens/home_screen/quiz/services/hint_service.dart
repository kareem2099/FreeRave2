import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hint_model.dart';

class HintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addHint(Hint hint) async {
    try {
      await _firestore.collection('hints').doc(hint.id).set(hint.toMap());
    } catch (e) {
      throw Exception('Failed to add hint: $e');
    }
  }

  Future<List<Hint>> getHints(String questionId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('hints')
          .where('questionId', isEqualTo: questionId)
          .get();
      return querySnapshot.docs.map((doc) => Hint.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch hints: $e');
    }
  }
}
