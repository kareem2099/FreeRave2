import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String userId;
  final bool isCurrentUser;

  const UserTile({super.key, required this.userData, required this.userId,  this.isCurrentUser = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: userData['photoUrl'] != null
          ? CircleAvatar(backgroundImage: NetworkImage(userData['photoUrl']))
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(userData['name']),
      subtitle:  isCurrentUser ? const Text('that u') : Text(userData['email']),
      trailing: !isCurrentUser ? StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .doc(userId)
            .snapshots(),
        builder: (context, requestSnapshot) {
          if (!requestSnapshot.hasData) {
            return IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                sendFriendRequest(context, userId);
              },
            );
          }

          final requestStatus = requestSnapshot.data!.data() as Map<String, dynamic>?;

          if (requestStatus == null) {
            return IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                sendFriendRequest(context, userId);
              },
            );
          }

          switch (requestStatus['status']) {
            case 'accepted':
              return const Icon(Icons.check_circle, color: Colors.green);
            case 'pending':
              return const Icon(Icons.timer, color: Colors.yellow);
            default:
              return IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  sendFriendRequest(context, userId);
                },
              );
          }
        },
      ) : null,
    );
  }
}

void sendFriendRequest(BuildContext context, String userId) async {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  try {
    await FirebaseFirestore.instance.collection('friend_requests').doc(userId).set({
      'senderId': currentUserId,
      'status': 'pending',
    });
    if(context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request sent!')),
    );
    }
  } catch (e) {
    // print('Failed to send friend request: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send friend request: $e')),
      );
    }
  }
}
