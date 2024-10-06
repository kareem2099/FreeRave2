import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });

  // Convert a User object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Create a User object from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
    );
  }

  @override
  List<Object?> get props => [id, name];
}
