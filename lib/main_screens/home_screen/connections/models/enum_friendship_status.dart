import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendshipStatus { pending, accepted, blocked, declined }

class Friend {
final String friendUid;
  final String name;
  final DateTime addedTime;
  final FriendshipStatus status;

  Friend({
    required this.friendUid,
    required this.name,
    required this.addedTime,
    this.status = FriendshipStatus.pending,
  });

  // Factory constructor to create a Friend from a map
  factory Friend.fromMap(Map<String, dynamic> data) {
    return Friend(
      friendUid: data['friendUid'] ?? '',
      name: data['name'] ?? '',
      addedTime: (data['addedTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: FriendshipStatus.values.byName(data['status'] ?? 'pending'),
    );
  }

  // Convert a Friend to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'friendUid': friendUid,
      'name': name,
      'addedTime': Timestamp.fromDate(addedTime),
      'status': status.name,
    };
  }

  // CopyWith method for friend object
  Friend copyWith({
    String? friendUid,
    String? name,
    DateTime? addedTime,
    FriendshipStatus? status,
  }) {
    return Friend(
      friendUid: friendUid ?? this.friendUid,
      name: name ?? this.name,
      addedTime: addedTime ?? this.addedTime,
      status: status ?? this.status,
    );
  }



// Method to calculate the duration of the friendship
  Duration getFriendshipDuration() {
    return DateTime.now().difference(addedTime);
  }

  // Method to get a formatted string for the friendship duration
  String getFormattedFriendshipDuration() {
    final duration = getFriendshipDuration();
    final years = duration.inDays ~/ 365;
    final months = (duration.inDays % 365) ~/ 30;
    final days = (duration.inDays % 365) % 30;
    return '$years years, $months months, $days days';
  }
}
