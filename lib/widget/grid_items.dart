import 'package:flutter/material.dart';

class GridItem {
  final IconData icon;
  final String label;

  GridItem({required this.icon, required this.label});
}

List<GridItem> gridItems = [
  // First 3: Connections, Chat, Games
  GridItem(icon: Icons.call, label: 'Connections'),
  GridItem(icon: Icons.message, label: 'Chat'),
  GridItem(icon: Icons.gamepad, label: 'Games'),

  // Second 3: Movies and Animes, Notes, Cut Loose
  GridItem(icon: Icons.movie, label: 'Movies & Animes'),
  GridItem(icon: Icons.note, label: 'Notes'),
  GridItem(icon: Icons.beach_access, label: 'Cut Loose'),

  // Third 3: Recommendations, Quiz and Answers, Manga and Manhwa
  GridItem(icon: Icons.recommend, label: 'Recommendations'),
  GridItem(icon: Icons.quiz, label: 'Quiz & Answers'),
  GridItem(icon: Icons.book, label: 'Manga & Manhwa'),
];
