import 'package:flutter/material.dart';
import 'package:freerave/main_file_components/bloc_providers.dart';
import 'package:freerave/main_file_components/stream_chat_client.dart';

import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'auth/screen/login_screen.dart';
import 'auth/services/auth_service.dart';
import 'main_file_components/app_routes.dart';
import 'package:freerave/main_screens/home_screen/public_chat/widget/chat_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFirebase();
  final client = initializeStreamChatClient();

  // Initialize AuthService (keep)
  final authService = AuthService();

  // Run the app
  runApp(MyApp(
    client: client,
    authService: authService,
  ));
}

class MyApp extends StatelessWidget {
  final StreamChatClient client;
  final AuthService authService;

  const MyApp({super.key, required this.client, required this.authService});

  @override
  Widget build(BuildContext context) {
    return appBlocProviders(
      client,
      authService,
      StreamChatTheme(
        data: streamChatThemeData,
        child: MaterialApp(
          title: 'FreeRave',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: LoginScreenWrapper(client: client),
          routes: getAppRoutes(client),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'EG'),
            Locale('es', 'ES'),
            Locale('fr', 'FR'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}

// A wrapper for LoginScreen that provides StreamChat only when needed
class LoginScreenWrapper extends StatelessWidget {
  final StreamChatClient client;

  const LoginScreenWrapper({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return StreamChat(
      client: client,
      child: const LoginScreen(),
    );
  }
}
