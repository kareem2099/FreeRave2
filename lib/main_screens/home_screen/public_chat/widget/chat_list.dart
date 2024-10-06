import 'package:flutter/material.dart';
import 'package:freerave/main_screens/home_screen/public_chat/widget/audio_loading_message.dart';
import 'package:freerave/main_screens/home_screen/public_chat/widget/audio_player_message.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'chat_loading_indicator.dart';

class ChatList extends StatelessWidget {
  final Function(String) onReaction;
  final Function(Message) onThreadReply;

  const ChatList({
    super.key,
    required this.onReaction,
    required this.onThreadReply,
  });

  @override
  Widget build(BuildContext context) {
    return StreamMessageListView(
      loadingBuilder: (context) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChatLoadingIndicator(),
            SizedBox(height: 10),
            Text('Loading Messages...'),
          ],
        );
      },
      messageBuilder: (context, messageDetails, messages, defaultMessage) {
        return defaultMessage.copyWith(
          showThreadReplyIndicator: true,
          showThreadReplyMessage: true,
          showDeleteMessage: true,
          showUserAvatar: DisplayWidget.show,
          reverse: true,
          showReactionBrowser: false,
          showReplyMessage: true,
          showFlagButton: true,
          showEditMessage: true,
          showReactions: true,
          onReactionsTap: (message) {
            onReaction(message.id);
          },
          onThreadTap: (message) {
            onThreadReply(message);
          },
          attachmentBuilders: [
            AudioAttachmentBuilder(),
            ...StreamAttachmentWidgetBuilder.defaultBuilders(
              message: messageDetails.message,
            ),
          ],
          textBuilder: (context, message) {
            return Text(message.text ?? '');
          },
        );
      },
    );
  }
}

class AudioAttachmentBuilder extends StreamAttachmentWidgetBuilder {
  @override
  Widget build(BuildContext context, Message message,
      Map<String, List<Attachment>> attachments) {
    final url = attachments['voicenote']?.first.assetUrl;
    late final Widget widget;
    if (url == null) {
      widget = const AudioLoadingMessage();
    } else {
      widget = AudioPlayerMessage(
        source: AudioSource.uri(Uri.parse(url)),
        id: message.id,
      );
    }
    return SizedBox(
      width: 250,
      height: 50,
      child: widget,
    );
  }

  @override
  bool canHandle(Message message, Map<String, List<Attachment>> attachments) {
    final audioAttachments = attachments['voicenote'];
    return audioAttachments != null && audioAttachments.length == 1;
  }
}
