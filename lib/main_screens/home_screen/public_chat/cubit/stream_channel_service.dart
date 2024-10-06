import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamChannelService {
  final StreamChatClient client;

  StreamChannelService(this.client);

  Future<Channel> initializeChannel(String channelId) async {
    try {
      final channel = client.channel('messaging', id: channelId);
      await channel.watch();
      return channel;
    } catch (e) {
      print("Error initializing channel: $e"); // Add this to log errors
      rethrow; // Optionally, rethrow the error to handle it at a higher level
    }
  }
}
