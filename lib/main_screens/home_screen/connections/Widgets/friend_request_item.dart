import 'package:flutter/material.dart';
import '../models/user_model.dart';

class FriendRequestItem extends StatelessWidget {
  final UserModel user;
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FriendRequestItem({
    super.key,
    required this.user,
    required this.status,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: user.photoUrl.isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(user.photoUrl))
            : const CircleAvatar(child: Icon(Icons.person)),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: onAccept,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onReject,
            ),
          ],
        ),
      ),
    );
  }
}
