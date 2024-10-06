import 'package:logger/logger.dart' as log;
import 'package:rxdart/rxdart.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamChatService {
  final StreamChatClient client;
  final log.Logger logger = log.Logger();

  StreamChatService(this.client);

  /// Connects a user to the Stream Chat client.
  Future<void> connectUser(User user, String token) async {
    try {
      // Check if the client is already connected
      if (client.wsConnectionStatus == ConnectionStatus.connected) {
        logger.e('User is already connected.');
        return;
      }
      // Connect the user if not connected
      await client.connectUser(user, token);
      logger.i('User connected successfully');
    } catch (e) {
      logger.e('Error connecting user: $e');
      rethrow;
    }
  }

  /// Disconnects the current user from the Stream Chat client.
  Future<void> disconnectUser() async {
    try {
      await client.disconnectUser();
    } catch (e) {
      logger.e('Error disconnecting user: $e');
      rethrow;
    }
  }

  /// Creates a new channel with the given [channelId].
  Future<Channel> createChannel(String channelId) async {
    try {
      final channel = client.channel('messaging', id: channelId);
      await channel.create();
      return channel;
    } catch (e) {
      logger.e('Error creating channel: $e');
      rethrow;
    }
  }

  /// Creates a new public channel with the given [channelId].
  Future<Channel> createPublicChannel(String channelId) async {
    try {
      final channel = client.channel('messaging', id: channelId, extraData: {
        'name': 'Public Chat',
        'image': 'https://path/to/image.png',
        'members': [],
      });
      await channel.create();
      return channel;
    } catch (e) {
      logger.e('Error creating public channel: $e');
      rethrow;
    }
  }

  /// Returns a stream of messages for the given [channel].
  Stream<List<Message>> getMessages(Channel channel) {
    try {
      return channel.state?.messagesStream ?? Stream.value([]);
    } catch (e) {
      logger.e('Error getting messages: $e');
      return Stream.value([]);
    }
  }

  /// Sends a message with the given [text] to the specified [channel].
  Future<void> sendMessage(Channel channel, String text) async {
    try {
      final message = Message(text: text);
      await channel.sendMessage(message);
    } catch (e) {
      logger.e('Error sending message: $e');
      rethrow;
    }
  }

  /// Returns a stream of user presence updates for the given [user].
  Stream<User?> getUserPresence(User user) {
    try {
      return client
          .on(EventType.userUpdated)
          .where((event) => event.user?.id == user.id)
          .map((event) => event.user);
    } catch (e) {
      logger.e('Error getting user presence: $e');
      return Stream.value(null);
    }
  }

  /// Returns a stream indicating whether a user is typing in the given [channel].
  Stream<bool> getTypingIndicator(Channel channel) {
    try {
      return Rx.merge([
        channel.on(EventType.typingStart).map((event) => true),
        channel.on(EventType.typingStop).map((event) => false),
      ]);
    } catch (e) {
      logger.e('Error getting typing indicator: $e');
      return Stream.value(false);
    }
  }

  // Start typing
  Future<void> startTyping(Channel channel) async {
    try {
      await channel.startTyping(); // Signal that the user is typing
    } catch (e) {
      logger.e('Error sending typing start indicator: $e');
      rethrow;
    }
  }

  // Stop typing
  Future<void> stopTyping(Channel channel) async {
    try {
      await channel.stopTyping(); // Signal that the user stopped typing
    } catch (e) {
      logger.e('Error sending typing stop indicator: $e');
      rethrow;
    }
  }

  // Reconnect user
  Future<void> reconnectUser(User user, String token) async {
    try {
      await Future.delayed(const Duration(seconds: 5));
      await disconnectUser(); // Ensure user is disconnected before reconnecting
      await connectUser(user, token);
      logger.i('User reconnected successfully');
    } catch (e) {
      logger.e('Error reconnecting user: $e');
      rethrow;
    }
  }

  /// Retrieves reactions for the message with the given [messageId].
  Future<QueryReactionsResponse> getReactions(String messageId,
      {PaginationParams? pagination}) async {
    try {
      return await client.getReactions(messageId, pagination: pagination);
    } catch (e) {
      logger.e('Error getting reactions: $e');
      rethrow;
    }
  }


  /// Sends a threaded reply to the given [parentMessage] with the specified [text].
  Future<SendMessageResponse> sendThreadedReply(
      Channel channel, Message parentMessage, String text) async {
    try {
      final message = Message(
        text: text,
        parentId: parentMessage.id,
        showInChannel: true,
      );
      return await channel.sendMessage(message);
    } catch (e) {
      logger.e('Error sending threaded reply: $e');
      rethrow;
    }
  }

  // Monitor connection status
  Stream<ConnectionStatus> monitorConnectionStatus() {
    return client.wsConnectionStatusStream;
  }
}
