import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/note_cubit.dart';
import '../auth/note_state.dart';
import '../model/note_model.dart';
import '../services/speech_service.dart';
import '../widget/note_dialog.dart';
import '../widget/note_list.dart';
import '../widget/search_bar.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  NotesScreenState createState() => NotesScreenState();
}

class NotesScreenState extends State<NotesScreen> {
  late NoteCubit _notesCubit;
  late SpeechService _speechService;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  String? _selectedTag;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _notesCubit = BlocProvider.of<NoteCubit>(context);
    _notesCubit.fetchNotes();
    _speechService = SpeechService();
    _speechService.initSpeech();
  }

  void _showNoteDialog(NoteModel? note) {
    showDialog(
      context: context,
      builder: (context) {
        return NoteDialog(
          notesCubit: _notesCubit,
          note: note,
          titleController: _titleController,
          contentController: _contentController,
        );
      },
    );
  }

  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _notesCubit.filterNotesByDate(picked.start, picked.end);
    }
  }

  void _selectTag(String? tag) {
    setState(() {
      _selectedTag = tag;
    });
    if (tag != null) {
      _notesCubit.filterNotesByTag(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150.0),
          child: Column(
            children: [
              SearchBarWidget(
                searchController: _searchController,
                notesCubit: _notesCubit,
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextField(
              //     controller: _tagController,
              //     decoration: InputDecoration(
              //       hintText: 'Enter tag...',
              //       suffixIcon: IconButton(
              //         icon: const Icon(Icons.add),
              //         onPressed: () {
              //           _selectTag(_tagController.text);
              //         },
              //       ),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12.0),
              //       ),
              //     ),
              //   ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _pickDateRange,
                    child: const Text('Select Date Range'),
                  ),
                  DropdownButton<String>(
                    value: _selectedTag,
                    hint: const Text('Filter by Tag'),
                    items: <String>['Work', 'Personal', 'Important'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: _selectTag,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<NoteCubit, NoteState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(child: Text('No notes available. Add a new note to get started!'));
            }
            return NoteList(
              notes: state.notes,
              notesCubit: _notesCubit,
              titleController: _titleController,
              contentController: _contentController,
              showNoteDialog: _showNoteDialog,
            );
          } else if (state is NotesError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Something went wrong. Please try again.'));
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isFabExpanded) ...[
            FloatingActionButton(
              onPressed: () {
                _titleController.clear();
                _contentController.clear();
                _showNoteDialog(null);
              },
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                if (!_speechService.isListening) {
                  _speechService.startListening((result) {
                    setState(() {
                      _contentController.text = result;
                    });
                  });
                } else {
                  _speechService.stopListening();
                }
              },
              child: const Icon(Icons.mic),
            ),
          ],
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _isFabExpanded = !_isFabExpanded;
              });
            },
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
