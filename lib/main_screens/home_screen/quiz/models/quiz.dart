import 'question.dart';

class Quiz {
  final String id;
  final String title;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
  });

  // Convert a Quiz object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  // Create a Quiz object from a Map
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      title: map['title'],
      questions: List<Question>.from(
          map['questions']?.map((q) => Question.fromMap(q))),
    );
  }
}
