import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main_screens/home_screen/connections/models/user_model.dart';

abstract class AuthState {}

// Initial state when the app starts
class AuthInitial extends AuthState {}

// State when an authentication process is loading
class AuthLoading extends AuthState {}

// State when a user is authenticated
class AuthAuthenticated extends AuthState {
  final User user;
  final Map<String, String?> userData;

  AuthAuthenticated(this.user, this.userData);
}

// State when a user is unauthenticated
class AuthUnauthenticated extends AuthState {}

// State when there is an error in the authentication process
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

// State when an action is successful
class AuthSuccess extends AuthState {
  final String message;

  AuthSuccess(this.message);
}

// State when registration is successful
class AuthRegistrationSuccess extends AuthState {}

// State when the user's email is not verified
class AuthEmailNotVerified extends AuthState {}

// State when an SMS code is sent for phone authentication
class AuthCodeSent extends AuthState {
  final String verificationId;

  AuthCodeSent(this.verificationId);
}

// State when user data is loaded
class AuthLoaded extends AuthState {
  final UserModel userModel;

  AuthLoaded(this.userModel);
}

class FriendRequestActionSuccess extends AuthState {}

// State when a friend request is sent
class AuthFriendRequestSent extends AuthState {}

// State when a friend request is accepted
class AuthFriendRequestAccepted extends AuthState {}

// State when a friend request is declined
class AuthFriendRequestDeclined extends AuthState {}

// State when pending friend requests are loaded
class AuthPendingFriendRequestsData extends AuthState {
  final List<FriendRequest> pendingRequests;
  final int requestCount;

  AuthPendingFriendRequestsData(this.pendingRequests)
      : requestCount = pendingRequests.length;
}

class FriendRequestSearchSuccess extends AuthState {
  final List<UserModel> friends;
  FriendRequestSearchSuccess(this.friends);
}

// State when a friend request is canceled
class AuthFriendRequestCancelled extends AuthState {}

class FriendRequestLoaded extends AuthState {
  final List<FriendRequestLoad> requests;

   FriendRequestLoaded(this.requests);
}

// State when a friend is blocked
class AuthFriendBlocked extends AuthState {}

// Model for a friend request
class FriendRequest {
  final String userId;


  FriendRequest(this.userId);
}

class FriendRequestLoad {
  final String userId;
  final UserModel sender; // The user who sent the request
  final DateTime status;

  FriendRequestLoad({
    required this.userId,
    required this.sender,
    required this.status,
  });

  factory FriendRequestLoad.fromDocument(DocumentSnapshot doc) {
    return FriendRequestLoad(
      userId: doc.id,
      sender: UserModel.fromDocument(doc['from']), // Assuming 'from' contains the user data or a reference
      status: doc['status'],
    );
  }

}



// State when the friend list is loaded
class AuthFriendListLoaded extends AuthState {
  final List<UserModel> friendList;

  AuthFriendListLoaded(this.friendList);
}

// State when the friendship anniversary is loaded
class AuthFriendshipAnniversaryLoaded extends AuthState {
  final Map<String, Duration> friendshipDurations;

  AuthFriendshipAnniversaryLoaded(this.friendshipDurations);
}

// State for friend request notifications
class AuthFriendRequestNotification extends AuthState {
  final String notificationMessage;

  AuthFriendRequestNotification(this.notificationMessage);
}

// Exception for network errors
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);
}

// State when there is a network error
class AuthNetworkError extends AuthState {
  final String message;

  AuthNetworkError(this.message);
}

// State when there is a server error
class AuthServerError extends AuthState {
  final String message;

  AuthServerError(this.message);
}

// Exception for user not found errors
class UserNotFoundException implements Exception {
  final String message;

  UserNotFoundException(this.message);
}

class FriendRequestException implements Exception {
  final String message;
  FriendRequestException(this.message);
}
