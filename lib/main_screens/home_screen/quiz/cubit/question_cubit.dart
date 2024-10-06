import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/hint_model.dart';
import '../models/question.dart';
import '../models/timer_model.dart';
import '../services/hint_service.dart';
import '../services/question_service.dart';
import '../services/timer_service.dart';
import '../states/question_state.dart';

class QuestionCubit extends Cubit<QuestionState> {
  final QuestionService questionService;
  final HintService hintService;
  final TimerService timerService;

  QuestionCubit({
    required this.questionService,
    required this.hintService,
    required this.timerService,
  }) : super(QuestionInitial());

  void addQuestion(Question question) async {
    try {
      emit(QuestionLoading());
      await questionService.addQuestion(question);
      emit(QuestionAdded(question: question));
    } catch (e) {
      emit(QuestionError(message: e.toString()));
    }
  }

  void updateQuestion(Question question) async {
    try {
      emit(QuestionLoading());
      await questionService.updateQuestion(question);
      emit(QuestionUpdated(question: question));
    } catch (e) {
      emit(QuestionError(message: e.toString()));
    }
  }

  void deleteQuestion(String questionId) async {
    try {
      emit(QuestionLoading());
      await questionService.deleteQuestion(questionId);
      emit(QuestionDeleted(questionId: questionId));
    } catch (e) {
      emit(QuestionError(message: e.toString()));
    }
  }

  void fetchQuestions(String quizId) async {
    try {
      emit(QuestionLoading());
      final questions = await questionService.getQuestions(quizId);
      emit(QuestionsLoaded(questions: questions));
    } catch (e) {
      emit(QuestionError(message: e.toString()));
    }
  }

  void setOptions(String questionId, List<String> options) async {
    try {
      emit(QuestionLoading());
      final question = await questionService.getQuestion(questionId);
      final updatedQuestion = Question(
        id: question.id,
        questionText: question.questionText,
        options: options,
        correctAnswer: question.correctAnswer,
      );
      await questionService.updateQuestion(updatedQuestion);
      emit(QuestionUpdated(question: updatedQuestion));
    } catch (e) {
      emit(QuestionError(message: e.toString()));
    }
  }

  void setTimer(String questionId, int duration) async {
    try {
      emit(QuestionLoading());
      final timerSetting = TimerSetting(
        id: DateTime.now().toString(),
        questionId: questionId,
        duration: duration,
      );
      await timerService.setTimer(timerSetting);
      emit(QuestionUpdated(question: await questionService.getQuestion(questionId)));
    } catch (e) {
      emit(QuestionError(message: e.toString()));
    }
  }

  void setHints(String questionId, List<Hint> hints) async {
    try {
      emit(QuestionLoading());
      for (var hint in hints) {
        await hintService.addHint(hint);
      }
      emit(QuestionUpdated(question: await questionService.getQuestion(questionId)));
    } catch (e) {
      emit(QuestionError(message: e.toString()));
    }
  }
}
