import 'package:flutter/material.dart';
import 'package:freerave/auth/screen/login_screen.dart';
import 'package:freerave/auth/screen/register_screen.dart';
import 'package:freerave/main_screens/main_navigation.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

Map<String, WidgetBuilder> getAppRoutes(StreamChatClient client) {
  return {
    '/home': (context) =>  MainNavigation(client: client,),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
  };
}
