// friend_request_state.dart
import '../../main_screens/home_screen/connections/models/user_model.dart';

abstract class FriendRequestState {}

// State when a friend request is sent
class FriendRequestSent extends FriendRequestState {}

// State when a friend request is accepted
class FriendRequestAccepted extends FriendRequestState {}

// State when a friend request is declined
class FriendRequestDeclined extends FriendRequestState {}

// State when pending friend requests are loaded
class PendingFriendRequestsLoaded extends FriendRequestState {
  final List<FriendRequest> pendingRequests;
  final int requestCount;

  PendingFriendRequestsLoaded(this.pendingRequests)
      : requestCount = pendingRequests.length;
}

// State for successful friend search
class FriendRequestSearchSuccess extends FriendRequestState {
  final List<UserModel> friends;
  FriendRequestSearchSuccess(this.friends);
}

// State when a friend request is canceled
class FriendRequestCancelled extends FriendRequestState {}

// State when a friend is blocked
class FriendBlocked extends FriendRequestState {}

// Model for a friend request
class FriendRequest {
  final String userId;

  FriendRequest(this.userId);
}

// State when the friend list is loaded
class FriendListLoaded extends FriendRequestState {
  final List<UserModel> friends;
  final bool isLoadingMore;

  FriendListLoaded({required this.friends, this.isLoadingMore = false});
}

// State when the friendship anniversary is loaded
class FriendshipAnniversaryLoaded extends FriendRequestState {
  final Map<String, Duration> friendshipDurations;

  FriendshipAnniversaryLoaded(this.friendshipDurations);
}

// State for friend request notifications
class FriendRequestNotification extends FriendRequestState {
  final String notificationMessage;

  FriendRequestNotification(this.notificationMessage);
}

// Exception for friend request errors
class FriendRequestException implements Exception {
  final String message;

  FriendRequestException(this.message);
}
