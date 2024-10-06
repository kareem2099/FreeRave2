import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/cubit/auth_state.dart';
import '../../../../auth/cubit/friend_request_cubit.dart';
import '../Widgets/friend_list_item.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<FriendRequestCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthFriendListLoaded) {
            final friends = state.friendList;
            if (friends.isEmpty) {
              return const Center(child: Text('No friends found.'));
            }
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return FriendListItem(user: friend);
              },
            );
          } else if (state is AuthError) {
            return _buildErrorMessage(state.message);
          } else {
            return const Center(child: Text('No friends data available.'));
          }
        },
      ),
    );
  }

  // Error Message Widget for Drawer
  Widget _buildErrorMessage(String message) {
    return Center(
      child: Text('Error: $message', style: const TextStyle(color: Colors.red)),
    );
  }
}
