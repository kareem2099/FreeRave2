import 'package:equatable/equatable.dart';

class TimerSetting extends Equatable {
  final String id;
  final String questionId;
  final int duration;

  const TimerSetting({
    required this.id,
    required this.questionId,
    required this.duration,
  });

  // Convert a TimerSetting object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'duration': duration,
    };
  }

  // Create a TimerSetting object from a Map
  factory TimerSetting.fromMap(Map<String, dynamic> map) {
    return TimerSetting(
      id: map['id'],
      questionId: map['questionId'],
      duration: map['duration'],
    );
  }

  @override
  List<Object?> get props => [id, questionId, duration];
}
