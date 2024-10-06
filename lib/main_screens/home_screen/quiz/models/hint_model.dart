import 'package:equatable/equatable.dart';

class Hint extends Equatable {
  final String id;
  final String questionId;
  final String hintText;

  const Hint({
    required this.id,
    required this.questionId,
    required this.hintText,
  });

  // Convert a Hint object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'hintText': hintText,
    };
  }

  // Create a Hint object from a Map
  factory Hint.fromMap(Map<String, dynamic> map) {
    return Hint(
      id: map['id'],
      questionId: map['questionId'],
      hintText: map['hintText'],
    );
  }

  @override
  List<Object?> get props => [id, questionId, hintText];
}
