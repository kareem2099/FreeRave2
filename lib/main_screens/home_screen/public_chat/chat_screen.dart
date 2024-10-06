// import 'package:flutter/material.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
//
// class ChatScreen extends StatefulWidget {
//   final StreamChatClient client;
//
//   const ChatScreen({Key? key, required this.client}) : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   late final _controller = StreamChannelListController(
//       client: widget.client,
//       filter: Filter.in_(
//         'members',
//         [widget.client.state.currentUser!.id],
//       ),
//       channelStateSort: const [SortOption('last_message_at')],
//       limit: 20);
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _controller.refresh,
//         child: StreamChannelListView(
//           controller: _controller,
//           onChannelTap: (channel) => Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (_) => StreamChannel(
//                 channel: channel,
//                 child: const ChannelPage(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ChannelPage extends StatelessWidget {
//   const ChannelPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final channel = StreamChannel.of(context).channel;
//
//     return const Scaffold(
//       appBar: StreamChannelHeader(),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: StreamMessageListView(),
//           ),
//           StreamMessageInput(),
//         ],
//       ),
//     );
//   }
// }
