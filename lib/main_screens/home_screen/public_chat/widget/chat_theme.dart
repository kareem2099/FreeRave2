import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

final streamChatThemeData = StreamChatThemeData(
  ownMessageTheme: const StreamMessageThemeData(
    messageBackgroundColor: Colors.amber,
    messageTextStyle: TextStyle(),
    avatarTheme: StreamAvatarThemeData(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),
  colorTheme: StreamColorTheme.dark(
    accentPrimary: const Color(0xffffe072),
  ),
  channelHeaderTheme: const StreamChannelHeaderThemeData(
    color: Color.fromARGB(255, 166, 70, 211),
    titleStyle: TextStyle(color: Color.fromARGB(255, 160, 124, 18)),
  ),
);
