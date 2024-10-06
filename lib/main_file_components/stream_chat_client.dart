import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../firebase_options.dart';
import '../main_screens/home_screen/public_chat/const.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
}

StreamChatClient initializeStreamChatClient() {
  return StreamChatClient(
    streamApiKey,
    logLevel: Level.INFO,
  );
}
