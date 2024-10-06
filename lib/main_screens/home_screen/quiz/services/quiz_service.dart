import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Quiz> getQuiz(String quizId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('quizzes').doc(quizId).get();
      return Quiz.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }

  Future<void> saveQuiz(Quiz quiz) async {
    try {
      await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toMap());
    } catch (e) {
      throw Exception('Failed to save quiz: $e');
    }
  }

  Future<List<Quiz>> getQuizzes() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('quizzes').get();
      return querySnapshot.docs.map((doc) => Quiz.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch quizzes: $e');
    }
  }
}
