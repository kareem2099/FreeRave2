import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final Timestamp timestamp;
  final String userId;
  final List<String> tags;
  final List<String> attachments;
  final int priority;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.userId,
    this.tags = const [],
    this.attachments = const [],
    this.priority = 0,
  });

  // Convert a Note object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'userId': userId,
      'tags': tags,
      'attachments': attachments,
      'priority': priority,
    };
  }

  // Create a Note object from a Map
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      timestamp: map['timestamp'],
      userId: map['userId'],
      tags: List<String>.from(map['tags'] ?? []),
      attachments: List<String>.from(map['attachments'] ?? []),
      priority: map['priority'] ?? 0,
    );
  }

  // Create a Note object from a Firestore DocumentSnapshot
  factory NoteModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'],
      content: data['content'],
      timestamp: data['timestamp'],
      userId: data['userId'],
      tags: List<String>.from(data['tags'] ?? []),
      attachments: List<String>.from(data['attachments'] ?? []),
      priority: data['priority'] ?? 0,
    );
  }

  // Add copyWith method
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    Timestamp? timestamp,
    String? userId,
    List<String>? tags,
    List<String>? attachments,
    int? priority,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      priority: priority ?? this.priority,
    );
  }
}
