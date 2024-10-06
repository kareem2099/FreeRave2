import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/cubit/auth_state.dart';
import '../../../../auth/cubit/friend_request_cubit.dart';
import '../../../../auth/services/friend_request_service.dart';
import '../Widgets/friend_request_item.dart';

class FriendRequestsScreen extends StatelessWidget {
  final String currentUserId;

  const FriendRequestsScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: BlocProvider(
        create: (context) => FriendRequestCubit(FriendRequestService()),
        child: BlocListener<FriendRequestCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is FriendRequestActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action successful')));
            }
          },
          child: StreamBuilder<List<FriendRequestLoad>>(
            stream: context.read<FriendRequestCubit>().getPendingFriendRequestsStream(currentUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Failed to load friend requests.'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No friend requests at the moment.'));
              }

              final friendRequests = snapshot.data!;

              return ListView.builder(
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  final request = friendRequests[index];
                  return FriendRequestItem(
                    user: request.sender,
                    status: 'Pending',
                    onAccept: () {
                      context.read<FriendRequestCubit>().acceptFriendRequest(
                          request.userId, currentUserId, request.sender.uid);
                    },
                    onReject: () {
                      context.read<FriendRequestCubit>().declineFriendRequest(
                          request.userId,currentUserId, request.sender.uid);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
