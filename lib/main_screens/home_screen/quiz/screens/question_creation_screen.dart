import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/question_cubit.dart';
import '../models/question.dart';
import '../states/question_state.dart';

class QuestionCreationScreen extends StatefulWidget {
  const QuestionCreationScreen({super.key});

  @override
  QuestionCreationScreenState createState() => QuestionCreationScreenState();
}

class QuestionCreationScreenState extends State<QuestionCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  String _correctAnswer = '';

  void _saveQuestion() {
    if (_formKey.currentState?.validate() ?? false) {
      final question = Question(
        id: UniqueKey().toString(),
        questionText: _questionController.text,
        options: _optionControllers.map((controller) => controller.text).toList(),
        correctAnswer: _correctAnswer,
      );
      context.read<QuestionCubit>().addQuestion(question);
    }
  }

  void _clearForm() {
    _questionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    setState(() {
      _correctAnswer = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a question';
                    }
                    return null;
                  },
                ),
                ..._optionControllers.map((controller) {
                  return TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Option'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an option';
                      }
                      return null;
                    },
                  );
                }).toList(),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _correctAnswer.isEmpty ? null : _correctAnswer,
                  decoration: const InputDecoration(labelText: 'Correct Answer'),
                  items: _optionControllers.map((controller) {
                    return DropdownMenuItem(
                      value: controller.text,
                      child: Text(controller.text),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _correctAnswer = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the correct answer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveQuestion,
                  child: const Text('Save Question'),
                ),
                BlocConsumer<QuestionCubit, QuestionState>(
                  listener: (context, state) {
                    if (state is QuestionAdded) {
                      _clearForm();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Question Added Successfully!')),
                      );
                    } else if (state is QuestionError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${state.message}')),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is QuestionLoading) {
                      return const CircularProgressIndicator();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
