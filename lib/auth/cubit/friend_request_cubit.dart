import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freerave/auth/cubit/auth_state.dart';
import 'package:freerave/auth/services/friend_request_service.dart';

class FriendRequestCubit extends Cubit<AuthState> {
  final FriendRequestService _friendRequestService;

  FriendRequestCubit(this._friendRequestService) : super(AuthInitial());

  /// Centralized error message handling.
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String generalErrorMessage = 'An unexpected error occurred. Please try again.';

  /// Generalized method to handle friend request actions and states.
  Future<void> _handleFriendRequest(
      Future<void> Function() action,
      String successMessage,
      String errorMessage,
      ) async {
    emit(AuthLoading());
    try {
      await action();
      emit(AuthSuccess(successMessage));
    } on NetworkException {
      emit(AuthNetworkError(networkErrorMessage));
    } catch (e) {
      emit(AuthError('$errorMessage: ${e.toString()}'));
    }
  }


  /// Friend Request Actions
  Future<void> acceptFriendRequest(String requestId, String currentUserId, String senderUserId) async {
    await _handleFriendRequest(
          () async {
        await _friendRequestService.acceptFriendRequest(requestId);
        getPendingFriendRequestsStream(currentUserId);
        // Additional business logic like creating a chat can be added here.
      },
      'Friend request accepted successfully.',
      'Failed to accept friend request',
    );
  }

  Future<void> declineFriendRequest( String requestId,String currentUserId, String senderId) async {
    await _handleFriendRequest(
          () => _friendRequestService.declineFriendRequest(requestId),
      'Friend request declined successfully.',
      'Failed to decline friend request',
    );
  }

  Future<void> sendFriendRequest(String currentUserUid, String friendUid) async {
    await _handleFriendRequest(
        () async {
          await _friendRequestService.sendFriendRequest(currentUserUid, friendUid);
        },
    'Friend request sent successfully.',
          'Failed to send friend request',
    );
  }

  // Future<void> sendFriendRequest(String currentUserId, String friendUserId) async {
  //   emit(AuthLoading());  // Use more specific loading states for better UI feedback.
  //   await _handleFriendRequest(
  //         () => _friendRequestService.sendFriendRequest(currentUserId, friendUserId),
  //     'Friend request sent successfully.',
  //     'Failed to send friend request',
  //   );
  // }

  Future<void> cancelFriendRequest(String currentUserId) async {
    await _handleFriendRequest(
          () => _friendRequestService.cancelFriendRequest(currentUserId),
      'Friend request cancelled successfully.',
      'Failed to cancel friend request',
    );
  }

  Future<void> blockUser(String currentUserId, String userId) async {
    await _handleFriendRequest(
          () => _friendRequestService.blockUser(currentUserId, userId),
      'User blocked successfully.',
      'Failed to block user',
    );
  }

  Future<void> unblockUser(String currentUserId, String userId) async {
    await _handleFriendRequest(
          () => _friendRequestService.unblockUser(currentUserId, userId),
      'User unblocked successfully.',
      'Failed to unblock user',
    );
  }

  Future<void> unfriend(String currentUserId, String friendUserId) async {
    await _handleFriendRequest(
          () => _friendRequestService.unfriend(currentUserId, friendUserId),
      'Unfriended successfully.',
      'Failed to unfriend',
    );
  }



  // Return a stream of friend requests
  Stream<List<FriendRequestLoad>> getPendingFriendRequestsStream(String currentUserId) {
    return _friendRequestService.getPendingFriendRequestsStream(currentUserId);
  }

  Future<void> fetchFriendList(String currentUserId) async {
    emit(AuthLoading());  // More specific states for feedback: `FetchingFriendList()`
    try {
      final friends = await _friendRequestService.getFriendList(currentUserId);
      emit(AuthFriendListLoaded(friends));
    } catch (e) {
      emit(AuthError('Failed to fetch friend list.'));
    }
  }

  Future<void> fetchFriendshipAnniversaries(String currentUserId) async {
    emit(AuthLoading());
    try {
      final anniversaries = await _friendRequestService.getFriendshipAnniversaries(currentUserId);
      emit(AuthFriendshipAnniversaryLoaded(anniversaries));
    } catch (e) {
      emit(AuthError('Failed to fetch friendship anniversaries.'));
    }
  }

  Future<void> fetchFriendshipDuration(String currentUserId, String friendUserId) async {
    emit(AuthLoading());
    try {
      final duration = await _friendRequestService.getFriendshipDuration(currentUserId, friendUserId);
      emit(AuthFriendshipAnniversaryLoaded({friendUserId: duration}));
    } catch (e) {
      emit(AuthError('Failed to fetch friendship duration.'));
    }
  }


  Future<void> searchFriends(String currentUserUid, String query) async {
    emit(AuthLoading());
    try {
      final friends = await _friendRequestService.searchFriends(query);
      emit(FriendRequestSearchSuccess(friends));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }


  // Future<void> searchFriends(String currentUserId, String searchQuery) async {
  //   emit(AuthLoading());  // Consider debouncing search queries.
  //   try {
  //     final searchResults = await _friendRequestService.searchFriends(currentUserId, searchQuery);
  //     emit(FriendRequestSearchSuccess(searchResults));
  //   } catch (error) {
  //     emit(AuthError('Error searching friends.'));
  //   }
  // }

  Future<void> sendFriendRequestNotification(String currentUserId, String friendUserId) async {
    await _handleFriendRequest(
          () => _friendRequestService.sendFriendRequestNotification(currentUserId, friendUserId),
      'Friend request notification sent.',
      'Failed to send friend request notification.',
    );
  }
}
