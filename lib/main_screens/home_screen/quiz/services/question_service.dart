import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addQuestion(Question question) async {
    try {
      await _firestore.collection('questions').doc(question.id).set(question.toMap());
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  Future<void> updateQuestion(Question question) async {
    try {
      await _firestore.collection('questions').doc(question.id).update(question.toMap());
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await _firestore.collection('questions').doc(questionId).delete();
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  Future<List<Question>> getQuestions(String quizId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('questions')
          .where('quizId', isEqualTo: quizId)
          .get();
      return querySnapshot.docs.map((doc) => Question.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<Question> getQuestion(String questionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('questions').doc(questionId).get();
      return Question.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch question: $e');
    }
  }
}
