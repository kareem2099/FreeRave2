import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionList extends StatefulWidget {
  final List<Question> questions;
  final Function(String questionId, String selectedOption) onOptionSelected;

  const QuestionList({
    Key? key,
    required this.questions,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  QuestionListState createState() => QuestionListState();
}

class QuestionListState extends State<QuestionList> {
  final Map<String, String> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.questions.length,
      itemBuilder: (context, index) {
        final question = widget.questions[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...question.options.map((option) {
                  return RadioListTile(
                    value: option,
                    groupValue: _selectedOptions[question.id],
                    onChanged: (value) {
                      setState(() {
                        _selectedOptions[question.id] = value as String;
                      });
                      widget.onOptionSelected(question.id, value as String);
                    },
                    title: Text(option),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
