// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_portal/flutter_portal.dart';
// import 'package:freerave/main_screens/home_screen/public_chat/cubit/stream_chat_state.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
// import '../cubit/stream_chat_cubit.dart';
// import '../widget/chat_list.dart';
// import '../widget/chat_message_input.dart';
// import 'package:freerave/auth/services/auth_service.dart'; // Import your AuthService

// class ChatPage extends StatefulWidget {
//   final Channel channel;
//   final StreamChatClient client;

//   const ChatPage({super.key, required this.channel, required this.client});

//   @override
//   ChatPageState createState() => ChatPageState();
// }

// class ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
//   late StreamChatCubit _cubit;
//   Timer? _debounce;
//   late AuthService _authService; // Instance for handling authentication

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _cubit = context.read<StreamChatCubit>();
//     WidgetsBinding.instance.addObserver(this);
//     _authService = AuthService(); // Initialize the AuthService
//     _initializeChat();
//   }

//   @override
//   void dispose() {
//     _cleanupResources();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _reconnectUser();
//     } else if (state == AppLifecycleState.paused) {
//       _disconnectUser();
//     }
//   }

//   void _initializeChat() {
//     _connectUser();
//     final currentUser = widget.client.state.currentUser;
//     if (currentUser != null) {
//       _cubit.monitorUserPresence(currentUser);
//     }
//     _cubit.monitorTypingIndicator(widget.channel);
//   }

//   void _cleanupResources() {
//     _cubit.disconnectUser();
//     WidgetsBinding.instance.removeObserver(this);
//     _debounce?.cancel();
//   }

//   Future<void> _connectUser() async {
//     try {
//       final firebaseUser = _authService.currentUser; // Get Firebase user

//       if (firebaseUser != null) {
//         // Generate StreamChat token for the Firebase user
//         final streamToken =
//             await _authService.getStreamChatToken(firebaseUser.uid);

//         // Connect the user to StreamChat using the token
//         await widget.client.connectUser(
//           User(id: firebaseUser.uid),
//           streamToken,
//         );

//         print('Connected to StreamChat as user ${firebaseUser.uid}');

//         // Monitor user presence and typing after connection
//         final currentUser = widget.client.state.currentUser;
//         if (currentUser != null) {
//           _cubit.monitorUserPresence(currentUser);
//         }
//         _cubit.monitorTypingIndicator(widget.channel);
//       } else {
//         print('No Firebase user is signed in.');
//       }
//     } catch (e) {
//       print('Failed to connect user: $e');
//     }
//   }

//   void _disconnectUser() {
//     _cubit.disconnectUser();
//   }

//   void _reconnectUser() async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult == ConnectivityResult.none) {
//       print('No internet connection, cannot reconnect.');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No internet connection.')),
//       );
//     } else if (widget.client.wsConnectionStatus != ConnectionStatus.connected) {
//       try {
//         _cubit.connectUser();
//         print('Reconnecting user...');
//       } catch (e, stacktrace) {
//         print('Reconnection failed: $e');
//         print('Stacktrace: $stacktrace');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Reconnection failed: $e')),
//         );
//       }
//     }
//   }

//   void _onTyping(String input) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       _cubit.sendTypingIndicator(widget.channel, isTyping: input.isNotEmpty);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamChat(
//       client: widget.client, // Ensure StreamChat wraps the chat page
//       child: Portal(
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('Public Chat'),
//           ),
//           body: StreamChannel(
//             channel: widget.channel,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ChatList(
//                     onReaction: (messageId) {
//                       _cubit.loadReactions(messageId);
//                     },
//                     onThreadReply: (message) {
//                       _cubit.sendThreadedReply(
//                           widget.channel, message, 'Reply text');
//                     },
//                   ),
//                 ),
//                 BlocBuilder<StreamChatCubit, PublicChatState>(
//                   builder: (context, state) {
//                     if (state is PublicChatLoading) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (state is PublicChatError) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Text(
//                                 'Error: ${state.error}',
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(color: Colors.red),
//                               ),
//                             ),
//                             ElevatedButton(
//                               onPressed: _connectUser,
//                               child: const Text('Retry'),
//                             ),
//                           ],
//                         ),
//                       );
//                     } else {
//                       return Column(
//                         children: [
//                           if (state is PublicChatTyping && state.isTyping)
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               child: Text(
//                                 '${state.typingUser?.name} is typing...',
//                                 style: const TextStyle(
//                                     fontStyle: FontStyle.italic),
//                               ),
//                             ),
//                           ChatMessageInput(
//                             channel: widget.channel,
//                           ),
//                         ],
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
