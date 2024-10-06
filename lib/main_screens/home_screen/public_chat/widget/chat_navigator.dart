import 'package:flutter/material.dart';
import 'package:freerave/main_screens/home_screen/public_chat/page/chat_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart'; // Import StreamChatClient

import '../cubit/stream_channel_service.dart';

class ChatNavigator {
  final StreamChannelService channelService;
  final StreamChatClient client;  // Add StreamChatClient here

  ChatNavigator(this.channelService, this.client);  // Add it in the constructor

  Future<void> navigateToChat(BuildContext context, String channelId) async {
    try {
      final channel = await channelService.initializeChannel(channelId);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              channel: channel,
              client: client,  // Pass the client to ChatPage
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chat channel: $e')),
        );
      }
    }
  }
}
