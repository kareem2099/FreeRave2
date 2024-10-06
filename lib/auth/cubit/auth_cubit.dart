import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;


class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final StreamChatClient _streamChatClient;

  AuthCubit(this._authService, this._streamChatClient) : super(AuthInitial()) {
    _authService.user.listen((user) async {
      if (user != null) {
        // print('User data received: $user');
        // Authenticate StreamChat user with Firebase's UID
        await _authenticateStreamChatUser(user);
        emit(AuthAuthenticated(user, {}));
      } else {
        // print('No user data received');
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _authenticateStreamChatUser(firebase_auth.User firebaseUser) async {
    try {
      // Get user details from the AuthService
      final userData = {
        'name': firebaseUser.displayName ?? 'Unknown',
        'email': firebaseUser.email ?? 'No email',
        'photoUrl': firebaseUser.photoURL ?? 'No photo',
      };

      // Get or generate token for StreamChat API using backend
      final streamToken =
          await _authService.getStreamChatToken(firebaseUser.uid);

      // Connect the user to StreamChat
      await _streamChatClient.connectUser(
        User(id: firebaseUser.uid, extraData: {
          'name': userData['name'],
          'image': userData['photoUrl'],
        }),
        streamToken,
      );

      emit(AuthAuthenticated(firebaseUser, userData));
    } catch (e) {
      emit(AuthError("Error authenticating chat user: ${e.toString()}"));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      emit(AuthLoading());
      await _authService.signInWithEmail(email, password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      emit(AuthLoading());
      await _authService.registerWithEmail(email, password);
      await Future.delayed(const Duration(seconds: 3));
      emit(AuthRegistrationSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      final userData = await _authService.signInWithGoogle();
      // print('Google sign-in user data: $userData');
      emit(AuthAuthenticated(_authService.currentUser!,
          userData)); // Or pass userData to the state
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      emit(AuthLoading());
      final userData = await _authService.signInWithFacebook();
      // print('Facebook sign-in user data: $userData');
      emit(AuthAuthenticated(_authService.currentUser!,
          userData)); // Or pass userData to the state
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }
}
