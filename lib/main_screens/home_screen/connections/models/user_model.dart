import 'package:cloud_firestore/cloud_firestore.dart';
import 'enum_friendship_status.dart';
import 'package:collection/collection.dart';


class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String bio;
  final String location;
  final List<Friend> friends;
  final Set<String> blockedUsers;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.bio,
    required this.location,
    required this.friends,
    required this.blockedUsers,
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserModel.empty(doc.id);
    }
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      bio: data['bio'] ?? '',
      location: data['location'] ?? '',
      friends: (data['friends'] as List<dynamic>? ?? [])
          .map((friend) => Friend.fromMap(friend))
          .toList(),
      blockedUsers: Set<String>.from(data['blockedUsers'] ?? []),
    );
  }

  // Handle empty data case
  factory UserModel.empty(String uid) {
    return UserModel(
      uid: uid,
      name: '',
      email: '',
      photoUrl: '',
      bio: '',
      location: '',
      friends: [],
      blockedUsers: {},
    );
  }

  // CopyWith method for updates
  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    String? location,
    List<Friend>? friends,
    Set<String>? blockedUsers,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      friends: friends ?? this.friends,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'location': location,
      'friends': friends.map((friend) => friend.toMap()).toList(),
      'blockedUsers': blockedUsers.toList(),
    };
  }

  // Methods to update user properties
  UserModel updateProfilePicture(String newPhotoUrl) => copyWith(photoUrl: newPhotoUrl);
  UserModel updateBio(String newBio) => copyWith(bio: newBio);
  UserModel updateLocation(String newLocation) => copyWith(location: newLocation);

  // Block and unblock users
  UserModel blockUser(String userId) => copyWith(blockedUsers: {...blockedUsers, userId});
  UserModel unblockUser(String userId) {
    final updatedBlockedUsers = Set<String>.from(blockedUsers);
    updatedBlockedUsers.remove(userId);
    return copyWith(blockedUsers: updatedBlockedUsers);
  }

  // Friend-related methods
  UserModel addFriend(Friend newFriend) => copyWith(friends: [...friends, newFriend]);
  UserModel removeFriend(String friendUid) {
    return copyWith(friends: friends.where((friend) => friend.friendUid != friendUid).toList());
  }


  UserModel updateFriendStatus(String friendUid, FriendshipStatus newStatus) {
    if (blockedUsers.contains(friendUid)) {
      throw Exception("Cannot update status for blocked user");
    }

    final updatedFriends = friends.map((friend) {
      if (friend.friendUid == friendUid) {
        return friend.copyWith(status: newStatus);
      }
      return friend;
    }).toList();

    return copyWith(friends: updatedFriends);
  }


  Friend? findFriend(String friendName) {
    try {
      return friends.firstWhere((friend) => friend.name == friendName);
    } catch (e) {
      return null;
    }
  }

  Friend? findFriendByUid(String friendUid) =>
      friends.firstWhereOrNull((friend) => friend.friendUid == friendUid);

  Friend? findFriendByName(String name) =>
      friends.firstWhereOrNull((friend) => friend.name == name);


  // Firestore save and delete methods
  Future<void> save() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(toMap());
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  Future<void> delete() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

}
