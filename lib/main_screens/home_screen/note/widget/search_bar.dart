import 'package:flutter/material.dart';
import 'dart:async';
import '../auth/note_cubit.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController searchController;
  final NoteCubit notesCubit;

  const SearchBarWidget({
    Key? key,
    required this.searchController,
    required this.notesCubit,
  }) : super(key: key);

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.notesCubit.searchNotes(widget.searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: widget.searchController,
        decoration: InputDecoration(
          hintText: 'Search Notes...',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              widget.searchController.clear();
              widget.notesCubit.searchNotes('');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onChanged: (text) => _onSearchChanged(),
      ),
    );
  }
}
