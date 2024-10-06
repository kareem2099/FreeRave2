import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Base class for all public chat states.
abstract class PublicChatState {}

/// Initial state when the chat is first loaded.
class PublicChatInitial extends PublicChatState {}

/// State when the user is connecting to the chat.
class PublicChatConnecting extends PublicChatState {}

/// State when the user is connected to the chat.
class PublicChatConnected extends PublicChatState {}

/// State when the user is disconnected from the chat.
class PublicChatDisconnected extends PublicChatState {}

/// State when an error occurs in the chat.
class PublicChatError extends PublicChatState {
  final String error;
  PublicChatError(this.error);
}

/// State when a general loading action is occurring.
class PublicChatLoading extends PublicChatState {}

/// State when messages are being loaded.
class PublicChatLoadingMessages extends PublicChatState {}

/// State when messages are loaded.
class PublicChatMessagesLoaded extends PublicChatState {
  final List<Message> messages;
  PublicChatMessagesLoaded(this.messages);
}

/// State when a message is being sent.
class PublicChatSendingMessage extends PublicChatState {}

/// State when a message is sent.
class PublicChatMessageSent extends PublicChatState {}

/// State when a user is typing.
class PublicChatTyping extends PublicChatState {
  final bool isTyping;
  final String? displayName;
  PublicChatTyping(this.isTyping ,{this.displayName});
}

/// State when reactions are being loaded.
class PublicChatLoadingReactions extends PublicChatState {}

/// State when reactions are loaded.
class PublicChatReactionsLoaded extends PublicChatState {
  final List<Reaction> reactions;
  PublicChatReactionsLoaded(this.reactions);
}
