import 'package:equatable/equatable.dart';
import '../models/quiz.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizInProgress extends QuizState {
  final Quiz quiz;

  const QuizInProgress({required this.quiz});

  @override
  List<Object> get props => [quiz];
}

class QuizCompleted extends QuizState {}

class QuizzesLoaded extends QuizState {
  final List<Quiz> quizzes;

  const QuizzesLoaded({required this.quizzes});

  @override
  List<Object> get props => [quizzes];
}

class QuizError extends QuizState {
  final String message;

  const QuizError({required this.message});

  @override
  List<Object> get props => [message];
}

class QuizSendingQuestions extends QuizState {
  const QuizSendingQuestions();
}
