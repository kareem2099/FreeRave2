import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ThreadPage extends StatelessWidget {
  final Message message;
  final Channel channel;

  const ThreadPage({
    Key? key,
    required this.message,
    required this.channel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thread: ${message.text}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamMessageListView(
              loadingBuilder: (context) => const Center(child: CircularProgressIndicator()),
              messageBuilder: (context, messageDetails, messages, defaultMessage) {
                return defaultMessage.copyWith(
                  showUserAvatar: DisplayWidget.show,
                  showReactionBrowser: false,
                  onReactionsTap: (message) {
                    // Handle reactions if needed
                  },
                );
              },
            ),
          ),
          _MessageInput(channel: channel),
        ],
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  final Channel channel;

  const _MessageInput({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  __MessageInputState createState() => __MessageInputState();
}

class __MessageInputState extends State<_MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      widget.channel.sendMessage(
        Message(text: _controller.text),
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Reply...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
