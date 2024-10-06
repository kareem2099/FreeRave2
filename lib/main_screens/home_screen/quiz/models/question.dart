import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  // Convert a Question object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  // Create a Question object from a Map
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      questionText: map['questionText'],
      options: List<String>.from(map['options']),
      correctAnswer: map['correctAnswer'],
    );
  }

  // Validate question data
  bool isValid() {
    return questionText.isNotEmpty &&
        options.length >= 2 &&
        options.contains(correctAnswer);
  }

  @override
  List<Object?> get props => [id, questionText, options, correctAnswer];
}
