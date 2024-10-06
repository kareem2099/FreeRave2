import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/quiz_service.dart';
import '../states/quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final QuizService quizService;

  QuizCubit({required this.quizService}) : super(QuizInitial());

  void startQuiz(String quizId) async {
    try {
      emit(QuizLoading());
      final quiz = await quizService.getQuiz(quizId);
      emit(QuizInProgress(quiz: quiz));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  void finishQuiz() {
    emit(QuizCompleted());
  }

  void fetchQuizzes() async {
    try {
      emit(QuizLoading());
      final quizzes = await quizService.getQuizzes();
      emit(QuizzesLoaded(quizzes: quizzes));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  void sendQuestionsToSecondUser(String quizId) async {
    try {
      emit(QuizLoading());
      // Logic to send questions to the second user
      emit(QuizInProgress(quiz: await quizService.getQuiz(quizId)));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }
}
