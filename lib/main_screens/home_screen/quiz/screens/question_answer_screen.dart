import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/question_cubit.dart';
import '../states/question_state.dart';

class QuestionAnswerScreen extends StatefulWidget {
  final String quizId;

  const QuestionAnswerScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  QuestionAnswerScreenState createState() => QuestionAnswerScreenState();
}

class QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  final Map<String, String> _selectedAnswers = {};

  void _submitAnswers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Answers'),
        content: const Text('Are you sure you want to submit your answers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Logic to submit answers
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
        title: const Text('Answer Questions'),
      ),
      body: BlocBuilder<QuestionCubit, QuestionState>(
        builder: (context, state) {
          if (state is QuestionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuestionsLoaded) {
            final questions = state.questions;
            return Column(
              children: [
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
                  onPressed: _submitAnswers,
                  child: const Text('Submit Answers'),
                ),
              ],
            );
          } else if (state is QuestionError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Loading questions...'));
        },
      ),
    );
  }
}
