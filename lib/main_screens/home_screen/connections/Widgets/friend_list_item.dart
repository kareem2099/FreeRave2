import 'package:flutter/material.dart';

import '../../../../auth/services/friend_request_service.dart';
import '../models/user_model.dart';

class FriendListItem extends StatefulWidget {
  final UserModel user;

  const FriendListItem({super.key, required this.user});

  @override
  State<FriendListItem> createState() => _FriendListItemState();
}

class _FriendListItemState extends State<FriendListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: widget.user.photoUrl.isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(widget.user.photoUrl))
            : const CircleAvatar(child: Icon(Icons.person)),
        title: Text(widget.user.name),
        subtitle: Text(widget.user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.block, color: Colors.red),
              onPressed: () => _handleBlockUser(context, widget.user.uid),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _handleUnblockUser(context, widget.user.uid),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBlockUser(BuildContext context, String userId) {
    _handleUserAction(context, userId, 'block');
  }

  void _handleUnblockUser(BuildContext context, String userId) {
    _handleUserAction(context, userId, 'unblock');
  }

  Future<void> _handleUserAction(BuildContext context, String userId, String action) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (action == 'block') {
        await FriendRequestService().blockUser('currentUserId', userId); // Add actual current user ID logic
      } else {
        await FriendRequestService().unblockUser('currentUserId', userId);
      }
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ${action}ed successfully')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to $action user: ${e.toString()}')));
      }
    }
  }
}
