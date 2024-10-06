import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main_screens/home_screen/connections/models/enum_friendship_status.dart';
import '../../main_screens/home_screen/connections/models/user_model.dart';
import '../cubit/auth_state.dart';

class FriendRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> sendFriendRequest(
      String currentUserUid, String friendUid) async {
    try {
      // Logic to add friend request in Firestore
      await _firestore.collection('friend_requests').add({
        'from': currentUserUid,
        'to': friendUid,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error sending friend request: $e');
    }
  }

  Stream<List<FriendRequestLoad>> getPendingFriendRequestsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('friend_requests')
        .where('to', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
      List<FriendRequestLoad> friendRequests = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Fetch the sender's user details from the 'users' collection
        DocumentSnapshot senderDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['from'])
            .get();

        final senderData = senderDoc.data() as Map<String, dynamic>;

        final sender = UserModel(
          uid: senderDoc.id,
          name: senderData['name'] ?? '',
          email: senderData['email'] ?? '',
          photoUrl: senderData['photoUrl'] ?? '',
          bio: senderData['bio'] ?? '',
          location: senderData['location'] ?? '',
          friends: (senderData['friends'] as List<dynamic>?)?.map((f) => Friend.fromMap(f)).toList() ?? [],
          blockedUsers: (senderData['blockedUsers'] as List<dynamic>?)?.map((user) => user.toString()).toSet() ?? {},
        );

        final friendRequest = FriendRequestLoad(
          userId: doc.id,
          sender: sender,
          status: (data['timestamp'] as Timestamp).toDate(), // Assuming status refers to the time request was sent
        );

        friendRequests.add(friendRequest);
      }

      return friendRequests;
    });
  }



  // Future<void> sendFriendRequest(String currentUserId, String friendUserId) async {
  //   try {
  //     final friendRef = _firestore.collection('users').doc(friendUserId);
  //     final currentUserRef = _firestore.collection('users').doc(currentUserId);
  //
  //     // Add a pending request to the friend's `friendRequests` field
  //     await _firestore.runTransaction((transaction) async {
  //       final friendSnapshot = await transaction.get(friendRef);
  //
  //       if (!friendSnapshot.exists) throw Exception("Friend user not found");
  //
  //       // Prepare friend object
  //       final newFriend = Friend(
  //         friendUid: currentUserId,
  //         name: (await currentUserRef.get()).data()?['name'] ?? 'Unknown',
  //         addedTime: DateTime.now(),
  //         status: FriendshipStatus.pending,
  //       );
  //
  //       // Add friend request to the friend
  //       transaction.update(friendRef, {
  //         'friendRequests': FieldValue.arrayUnion([newFriend.toMap()])
  //       });
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to send friend request: ${e.toString()}');
  //   }
  // }

  Stream<List<FriendRequestLoad>> getPendingFriendRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('to', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FriendRequestLoad.fromDocument(doc);
      }).toList();
    });
  }

  // Future<List<FriendRequest>> getPendingFriendRequests(String userId) async {
  //   try {
  //     final userRef = _firestore.collection('users').doc(userId);
  //     final userSnapshot = await userRef.get();
  //
  //     if (userSnapshot.exists) throw Exception("User not found");
  //
  //     final data = userSnapshot.data() as Map<String, dynamic>;
  //     final friendRequests = data['friendRequests'] as List<dynamic>;
  //     return friendRequests.map((id) => FriendRequest(id as String)).toList();
  //   } catch (e) {
  //     throw Exception('Failed to get pending friend requests: ${e.toString()}');
  //   }
  // }

  // Future<void> declineFriendRequest(String currentUserId, String senderUserId) async {
  //   try {
  //     final userRef = _firestore.collection('users').doc(currentUserId);
  //     await userRef.update({
  //       'friendRequests': FieldValue.arrayRemove([senderUserId]),
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to decline friend request: ${e.toString()}');
  //   }
  // }

  Future<void> _runFriendTransaction(String currentUserId, String friendUserId,
      Function(Transaction, DocumentSnapshot, DocumentSnapshot) action) async {
    final userRef = _firestore.collection('users').doc(currentUserId);
    final friendRef = _firestore.collection('users').doc(friendUserId);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final friendSnapshot = await transaction.get(friendRef);

      if (!userSnapshot.exists || !friendSnapshot.exists) {
        throw UserNotFoundException('User or Friend not found');
      }
      action(transaction, userSnapshot, friendSnapshot);
    });
  }

  Future<void> declineFriendRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': 'declined'});
  }

  // Future<void> acceptFriendRequest(String currentUserId, String senderUserId) async {
  //   await _runFriendTransaction(currentUserId, senderUserId, (transaction, userSnapshot, senderSnapshot) {
  //     // Update current user's friends and remove the friend request
  //     final senderData = senderSnapshot.data() as Map<String, dynamic>;
  //     final senderName = senderData['name'] ?? 'Unknown';
  //
  //     // Create Friend objects
  //     final newFriendForUser = Friend(
  //       friendUid: senderUserId,
  //       name: senderName,
  //       addedTime: DateTime.now(),
  //       status: FriendshipStatus.accepted,
  //     );
  //     final newFriendForSender = Friend(
  //       friendUid: currentUserId,
  //       name: userSnapshot['name'],
  //       addedTime: DateTime.now(),
  //       status: FriendshipStatus.accepted,
  //     );
  //
  //     // Update both user's friends and remove pending friend requests
  //     transaction.update(userSnapshot.reference, {
  //       'friends': FieldValue.arrayUnion([newFriendForUser.toMap()]),
  //       'friendRequests': FieldValue.arrayRemove([senderUserId]),
  //     });
  //     transaction.update(senderSnapshot.reference, {
  //       'friends': FieldValue.arrayUnion([newFriendForSender.toMap()]),
  //     });
  //   });
  // }

  // Accept a friend request
  Future<void> acceptFriendRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': 'accepted'});
  }

  Future<List<UserModel>> getFriendList(String userId) async {
    try {
      final userSnapshot = await _getUserSnapshot(userId);
      final data = userSnapshot.data() as Map<String, dynamic>;
      final friends = List<String>.from(data['friends'] ?? []);

      // Batch load friends data in parallel
      final friendDocs = await Future.wait(friends.map((friendId) async {
        return _firestore.collection('users').doc(friendId).get();
      }));

      return friendDocs.map((doc) => UserModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get friend list: ${e.toString()}');
    }
  }

  Future<UserModel> getUserData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromDocument(doc);
    }
    throw Exception("User not logged in");
  }

  Future<void> sendFriendRequestNotification(
      String currentUserId, String friendUserId) async {
    try {
      final userRef = _firestore.collection('users').doc(currentUserId);
      final friendRef = _firestore.collection('users').doc(friendUserId);

      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        final friendSnapshot = await transaction.get(friendRef);

        if (userSnapshot.exists && friendSnapshot.exists) {
          // Assuming you have a notifications collection
          final notificationRef = _firestore.collection('notifications').doc();
          await notificationRef.set({
            'from': currentUserId,
            'to': friendUserId,
            'message': 'You have a new friend request',
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception(
          'Failed to send friend request notification: ${e.toString()}');
    }
  }

  Future<List<UserModel>> searchFriends(String query) async {
    try {
      final searchByName = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final searchById = await _firestore
          .collection('users')
          .where('uid', isEqualTo: query)
          .get();

      List<UserModel> users = [];
      for (var doc in [...searchByName.docs, ...searchById.docs]) {
        users.add(UserModel.fromDocument(doc));
      }

      return users;
    } catch (e) {
      throw Exception('Error searching friends: $e');
    }
  }

  // Future<List<UserModel>> searchFriends(String currentUserId, String searchQuery) async {
  //   try {
  //     final query = _firestore.collection('users')
  //         .where('name', isGreaterThanOrEqualTo: searchQuery)
  //         .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
  //
  //     final resultsByName = await query.get();
  //
  //     final queryById = _firestore.collection('users')
  //         .where('uid', isEqualTo: searchQuery); // Search by ID as well
  //
  //     final resultsById = await queryById.get();
  //
  //     final combinedResults = resultsByName.docs + resultsById.docs;
  //     final uniqueResults = {for (var doc in combinedResults) doc.id: doc}.values.toList(); // Ensure no duplicates
  //
  //     return uniqueResults.map((doc) => UserModel.fromDocument(doc)).toList();
  //   } catch (e) {
  //     throw Exception('Error searching friends: ${e.toString()}');
  //   }
  // }

  Future<List<UserModel>> filterFriendsByStatus(
      String currentUserId, String status) async {
    final friendsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends');

    final querySnapshot = await friendsCollection
        .where('status',
            isEqualTo: status) // Filter by status (accepted, blocked, etc.)
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .toList();
  }

  Future<DocumentSnapshot> _getUserSnapshot(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userSnapshot = await userRef.get();
    if (!userSnapshot.exists) {
      throw UserNotFoundException("User not found");
    }
    return userSnapshot;
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).delete();
    } catch (e) {
      throw Exception('Error canceling friend request: $e');
    }
  }

  // Future<void> cancelFriendRequest(
  //     String currentUserId, String friendUserId) async {
  //   try {
  //     final friendRef = _firestore.collection('users').doc(friendUserId);
  //
  //     await _firestore.runTransaction((transaction) async {
  //       final friendSnapshot = await transaction.get(friendRef);
  //
  //       if (friendSnapshot.exists) {
  //         transaction.update(friendRef, {
  //           'friendRequests': FieldValue.arrayRemove([currentUserId])
  //         });
  //       } else {
  //         throw Exception("Friend user not found");
  //       }
  //     });
  //   } on SocketException {
  //     throw NetworkException(
  //         'Network error: Please check your internet connection.');
  //   } catch (e) {
  //     throw Exception('Failed to cancel friend request: ${e.toString()}');
  //   }
  // }

  Future<void> blockUser(String currentUserId, String userId) async {
    try {
      final currentUser =
          await _firestore.collection('users').doc(currentUserId).get();
      final userModel = UserModel.fromDocument(currentUser);

      final updatedUser = userModel.blockUser(userId);
      await updatedUser
          .save(); // Save the blocked user status back to Firestore
    } catch (e) {
      throw Exception('Failed to block user: ${e.toString()}');
    }
  }

  Future<void> unblockUser(String currentUserId, String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(currentUserId);
      await userRef.update({
        'blockedUsers': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to unblock user: ${e.toString()}');
    }
  }

  Future<Map<String, Duration>> getFriendshipAnniversaries(
      String userId) async {
    try {
      final userSnapshot = await _getUserSnapshot(userId);
      final data = userSnapshot.data() as Map<String, dynamic>;
      final friends = data['friends'] as List<dynamic>;
      final friendshipDurations = <String, Duration>{};

      for (var friendId in friends) {
        final friendSnapshot = await _getUserSnapshot(friendId as String);
        final friendData = friendSnapshot.data() as Map<String, dynamic>;
        final friendSince = friendData['friendSince'] as Timestamp;
        final duration = DateTime.now().difference(friendSince.toDate());
        friendshipDurations[friendId] = duration;
      }

      return friendshipDurations;
    } catch (e) {
      throw Exception(
          'Failed to get friendship anniversaries: ${e.toString()}');
    }
  }

  Future<void> unfriend(String currentUserId, String friendUserId) async {
    try {
      final userRef = _firestore.collection('users').doc(currentUserId);
      final friendRef = _firestore.collection('users').doc(friendUserId);

      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        final friendSnapshot = await transaction.get(friendRef);

        if (userSnapshot.exists && friendSnapshot.exists) {
          transaction.update(userRef, {
            'friends': FieldValue.arrayRemove([friendUserId])
          });
          transaction.update(friendRef, {
            'friends': FieldValue.arrayRemove([currentUserId])
          });
        }
      });
    } on SocketException {
      throw NetworkException(
          'Network error: Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to unfriend: ${e.toString()}');
    }
  }

  Future<Duration> getFriendshipDuration(
      String currentUserId, String friendUserId) async {
    try {
      final userRef = _firestore.collection('users').doc(currentUserId);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        final friends = data['friends'] as List<dynamic>;

        if (friends.contains(friendUserId)) {
          final friendSince = data['friendSince'] as Timestamp;
          return DateTime.now().difference(friendSince.toDate());
        } else {
          throw Exception("Friend not found in user's friend list");
        }
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      throw Exception('Failed to get friendship duration: ${e.toString()}');
    }
  }
}
