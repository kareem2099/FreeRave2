import 'package:equatable/equatable.dart';
import '../models/question.dart';

abstract class QuestionState extends Equatable {
  const QuestionState();

  @override
  List<Object> get props => [];
}

class QuestionInitial extends QuestionState {}

class QuestionLoading extends QuestionState {}

class QuestionAdded extends QuestionState {
  final Question question;

  const QuestionAdded({required this.question});

  @override
  List<Object> get props => [question];
}

class QuestionUpdated extends QuestionState {
  final Question question;

  const QuestionUpdated({required this.question});

  @override
  List<Object> get props => [question];
}

class QuestionDeleted extends QuestionState {
  final String questionId;

  const QuestionDeleted({required this.questionId});

  @override
  List<Object> get props => [questionId];
}

class QuestionsLoaded extends QuestionState {
  final List<Question> questions;

  const QuestionsLoaded({required this.questions});

  @override
  List<Object> get props => [questions];
}

class QuestionError extends QuestionState {
  final String message;

  const QuestionError({required this.message});

  @override
  List<Object> get props => [message];
}

class QuestionsPreparing extends QuestionState {
  const QuestionsPreparing();
}

class QuestionsSent extends QuestionState {
  const QuestionsSent();
}
