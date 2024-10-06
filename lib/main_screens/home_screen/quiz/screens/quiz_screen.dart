import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/timer_cubit.dart';
import '../states/quiz_state.dart';
import '../states/timer_state.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({Key? key, required this.quizId}) : super(key: key);

  @override
   createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  final Map<String, String> _selectedAnswers = {};

  void _submitQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz'),
        content: const Text('Are you sure you want to submit the quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<QuizCubit>().finishQuiz();
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuizInProgress) {
            final questions = state.quiz.questions;
            return Column(
              children: [
                BlocBuilder<TimerCubit, TimerState>(
                  builder: (context, timerState) {
                    if (timerState is TimerRunning) {
                      return Text('Time left: ${timerState.timeLeft}');
                    } else if (timerState is TimerFinished) {
                      return const Text('Time is up!');
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return ListTile(
                        title: Text(question.questionText),
                        subtitle: Column(
                          children: question.options.map((option) {
                            return RadioListTile(
                              value: option,
                              groupValue: _selectedAnswers[question.id],
                              onChanged: (value) {
                                setState(() {
                                  _selectedAnswers[question.id] = value as String;
                                });
                              },
                              title: Text(option),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitQuiz,
                  child: const Text('Submit Quiz'),
                ),
              ],
            );
          } else if (state is QuizCompleted) {
            return const Center(child: Text('Quiz Completed!'));
          } else if (state is QuizError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Welcome to the Quiz!'));
        },
      ),
    );
  }
}
