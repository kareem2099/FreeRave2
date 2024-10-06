import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../cubit/stream_chat_cubit.dart';
import '../cubit/stream_chat_state.dart';
import '../widget/chat_list.dart';
import '../widget/chat_message_input.dart';
import 'package:freerave/auth/services/auth_service.dart';

import '../widget/reaction_picker.dart';
import '../widget/thread_page.dart';

class ChatPage extends StatefulWidget {
  final Channel channel;
  final StreamChatClient client;

  const ChatPage({super.key, required this.channel, required this.client});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  late StreamChatCubit _cubit;
  Timer? _debounce;
  late AuthService _authService; // Instance for handling authentication

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<StreamChatCubit>();
    WidgetsBinding.instance.addObserver(this);
    _authService = AuthService(); // Initialize the AuthService
    _initializeChat();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cleanupResources();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reconnectUser();
    } else if (state == AppLifecycleState.paused) {
      _disconnectUser();
    }
  }

  void _initializeChat() async {
    await _connectUser();
    final currentUser = widget.client.state.currentUser;
    if (currentUser != null) {
      _cubit.monitorUserPresence(currentUser);
    }
    final displayName = _authService.currentUser?.displayName ?? 'User ${_authService.currentUser?.uid}';
    _cubit.monitorTypingIndicator(widget.channel, displayName);
  }


  void _cleanupResources() {
    _cubit.disconnectUser();
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
  }

  Future<void> _connectUser() async {
    try {
      final firebaseUser = _authService.currentUser; // Get Firebase user

      if (firebaseUser != null) {
        // Fetch the Firebase display name (or set a default if it's null)
        final displayName =
            firebaseUser.displayName ?? 'User ${firebaseUser.uid}';

        // Generate StreamChat token for the Firebase user
        final streamToken =
            await _authService.getStreamChatToken(firebaseUser.uid);

        // Connect the user to StreamChat using the token
        await widget.client.connectUser(
          User(id: firebaseUser.uid),
          streamToken,
        );

        print('Connected to StreamChat as user ${firebaseUser.uid}');

        // Monitor user presence and typing after connection
        final currentUser = widget.client.state.currentUser;
        if (currentUser != null) {
          _cubit.monitorUserPresence(currentUser);
        }
        _cubit.monitorTypingIndicator(widget.channel,displayName);
      } else {
        print('No Firebase user is signed in.');
      }
    } catch (e) {
      print('Failed to connect user: $e');
    }
  }

  void _disconnectUser() {
    _cubit.disconnectUser();
  }

  void _reconnectUser() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      print('No internet connection, cannot reconnect.');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection.')),
        );
      }
    } else if (widget.client.wsConnectionStatus != ConnectionStatus.connected) {
      try {
        _cubit.connectUser();
        print('Reconnecting user...');
      } catch (e, stacktrace) {
        print('Reconnection failed: $e');
        print('Stacktrace: $stacktrace');
        if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reconnection failed: $e')),
        );
        }
      }
    }
  }

  void _onTyping(String input) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _cubit.sendTypingIndicator(widget.channel, isTyping: input.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamChat(
      client: widget.client,
      child: Portal(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Public Chat'),
          ),
          body: StreamChannel(
            channel: widget.channel,
            child: Column(
              children: [
                Expanded(
                  child: ChatList(
                    onReaction: (messageId) async {
                      final reaction = await showReactionPicker(context);
                      _cubit.loadReactions( messageId);
                    },
                    onThreadReply: (message) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ThreadPage(message: message, channel: widget.channel),
                        ),
                      );

                    },
                  ),
                ),
                BlocBuilder<StreamChatCubit, PublicChatState>(
                  builder: (context, state) {
                    if (state is PublicChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PublicChatError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Error: ${state.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _connectUser,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          if (state is PublicChatTyping && state.isTyping)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                '${state.displayName} is typing...',
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ChatMessageInput(
                            channel: widget.channel,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
