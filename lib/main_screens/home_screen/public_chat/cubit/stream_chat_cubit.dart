import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freerave/auth/services/auth_service.dart';
import 'package:freerave/main_screens/home_screen/public_chat/cubit/stream_chat_state.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:logger/logger.dart' as log;
import 'stream_chat_service.dart';

class StreamChatCubit extends Cubit<PublicChatState> {
  final StreamChatService chatService;
  final AuthService authService;
  final log.Logger logger = log.Logger();
  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription<User?>? _userPresenceSubscription;
  StreamSubscription<bool>? _typingIndicatorSubscription;
  StreamSubscription<ConnectionStatus>? _connectionStatusSubscription;

  StreamChatCubit(this.chatService, this.authService)
      : super(PublicChatInitial());

  // Connect the user to Stream Chat
  Future<void> connectUser() async {
    try {
      emit(PublicChatConnecting());
      final userInfo = authService.getUserInfo();
      final user = User(
        id: userInfo['userID']!,
        extraData: {
          'name': userInfo['name'],
          'email': userInfo['email'],
          'image': userInfo['photoUrl'],
        },
      );
      final token = await authService.getStreamChatToken(user.id);
      await chatService.connectUser(user, token);
      // Monitor the connection status
      monitorConnectionStatus(user, token);
      emit(PublicChatConnected());
    } catch (e) {
      logger.e('Error connecting user: $e');
      emit(PublicChatError('Error connecting user: ${e.toString()}'));
    }
  }

  // Disconnect the user from Stream Chat
  Future<void> disconnectUser() async {
    try {
      await chatService.disconnectUser();
      emit(PublicChatDisconnected());
    } catch (e) {
      logger.e('Error disconnecting user: $e');
      emit(PublicChatError('Error disconnecting user: ${e.toString()}'));
    }
  }

  // Reconnect the user
  Future<void> reconnectUser() async {
    try {
      emit(PublicChatConnecting());
      final userInfo = authService.getUserInfo();
      final user = User(
        id: userInfo['userID']!,
        extraData: {
          'name': userInfo['name'],
          'email': userInfo['email'],
          'image': userInfo['photoUrl'],
        },
      );
      final token = await authService.getStreamChatToken(user.id);
      await chatService.reconnectUser(user, token);
      emit(PublicChatConnected());
    } catch (e) {
      logger.e('Error reconnecting user: $e');
      emit(PublicChatError('Error reconnecting user: ${e.toString()}'));
    }
  }

  // Monitor the connection status
  Future<void> monitorConnectionStatus(User user, String token) async {
    _connectionStatusSubscription =
        chatService.monitorConnectionStatus().listen((status) {
      if (status == ConnectionStatus.disconnected) {
        logger.i('User disconnected, attempting to reconnect...');
        reconnectUser(); // Automatically reconnect when disconnected
      }
    });
  }

  Future<void> loadMessages(Channel channel) async {
    try {
      emit(PublicChatLoadingMessages());
      final messagesStream = chatService.getMessages(channel);
      _messagesSubscription = messagesStream.listen((messages) {
        emit(PublicChatMessagesLoaded(messages));
      });
    } catch (e) {
      logger.e('Error loading messages: $e');
      emit(PublicChatError('Error loading messages: ${e.toString()}'));
    }
  }

  Future<void> sendMessage(Channel channel, String message) async {
    try {
      emit(PublicChatSendingMessage()); // Emitting the sending state
      await chatService.sendMessage(channel, message);

      // Log to ensure the message was sent successfully
      logger.i('Message sent successfully: $message');

      // After sending the message, emit a new state
      emit(PublicChatMessageSent());

      // Optionally, call loadMessages() to refresh the messages
      await loadMessages(channel);
    } catch (e) {
      logger.e('Error sending message: $e');
      emit(PublicChatError('Error sending message: ${e.toString()}'));
    }
  }


  Future<void> monitorUserPresence(User user) async {
    try {
      final presenceStream = chatService.getUserPresence(user);
      _userPresenceSubscription = presenceStream.listen((user) {
        // Handle user presence updates
      });
    } catch (e) {
      logger.e('Error monitoring user presence: $e');
      emit(PublicChatError('Error monitoring user presence: ${e.toString()}'));
    }
  }

  Future<void> monitorTypingIndicator(Channel channel,String displayName) async {
    try {
      final typingStream = chatService.getTypingIndicator(channel);
      _typingIndicatorSubscription = typingStream.listen((isTyping) {
        emit(PublicChatTyping(isTyping,displayName: displayName));
      });
    } catch (e) {
      logger.e('Error monitoring typing indicator: $e');
      emit(PublicChatError(
          'Error monitoring typing indicator: ${e.toString()}'));
    }
  }

  Future<void> loadReactions(String messageId) async {
    try {
      emit(PublicChatLoadingReactions());
      final reactionsResponse = await chatService.getReactions(messageId);
      emit(PublicChatReactionsLoaded(reactionsResponse.reactions));
    } catch (e) {
      logger.e('Error loading reactions: $e');
      emit(PublicChatError('Error loading reactions: ${e.toString()}'));
    }
  }

  Future<void> refreshToken(User user) async {
    try {
      final token = await authService.getStreamChatToken(user.id);
      await chatService.connectUser(user, token);
      emit(PublicChatConnected());
    } catch (e) {
      logger.e('Error refreshing token: $e');
      emit(PublicChatError('Error refreshing token: ${e.toString()}'));
    }
  }

  Future<void> sendThreadedReply(
      Channel channel, Message parentMessage, String text) async {
    try {
      emit(PublicChatSendingMessage());
      await chatService.sendThreadedReply(channel, parentMessage, text);
      emit(PublicChatMessageSent());
    } catch (e) {
      logger.e('Error sending threaded reply: $e');
      emit(PublicChatError('Error sending threaded reply: ${e.toString()}'));
    }
  }

  Future<void> sendFileMessage(Channel channel, File file) async {
    try {
      final attachment = Attachment(
        type: 'file',
        uploadState: const UploadState.success(),
        file: AttachmentFile(
          path: file.path,
          size: await file.length(),
        ),
      );

      final message = Message(
        attachments: [attachment],
      );

      await channel.sendMessage(message);
      logger.i('File message sent successfully');
    } catch (e) {
      logger.e('Error sending file message: $e');
      emit(PublicChatError('Error sending file message: ${e.toString()}'));
    }
  }

  // Updated method to use startTyping and stopTyping
  Future<void> sendTypingIndicator(Channel channel,
      {required bool isTyping}) async {
    try {
      if (isTyping) {
        await chatService.startTyping(channel);
      } else {
        await chatService.stopTyping(channel);
      }
    } catch (e) {
      logger.e('Error sending typing indicator: $e');
      emit(PublicChatError('Error sending typing indicator: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _userPresenceSubscription?.cancel();
    _typingIndicatorSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    return super.close();
  }
}
