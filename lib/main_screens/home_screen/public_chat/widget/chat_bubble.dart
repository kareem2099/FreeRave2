// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';

// class ChatBubble extends StatelessWidget {
//   final Message message;
//   final Function(String) onReaction;
//   final Function(Message) onThreadReply;

//   const ChatBubble(
//       {super.key,
//       required this.message,
//       required this.onReaction,
//       required this.onThreadReply});

//   @override
//   Widget build(BuildContext context) {
//     bool isMyMessage =
//         message.user?.id == StreamChat.of(context).currentUser?.id;

//     final Attachment? attachment = message.attachments.firstWhere(
//       (attachment) => attachment.type == 'voicenote',
//       orElse: () => null,
//     );

//     return Align(
//       alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//         padding: const EdgeInsets.all(12.0),
//         decoration: BoxDecoration(
//           color: isMyMessage ? Colors.blueAccent : Colors.grey[300],
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(12),
//             topRight: const Radius.circular(12),
//             bottomLeft: isMyMessage ? const Radius.circular(12) : Radius.zero,
//             bottomRight: isMyMessage ? Radius.zero : const Radius.circular(12),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment:
//               isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             if (!isMyMessage) ...[
//               Row(
//                 children: [
//                   CircleAvatar(
//                     backgroundImage: NetworkImage(
//                         message.user?.extraData['image'] as String? ?? ''),
//                     radius: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     message.user?.extraData['name'] as String? ?? 'Anonymous',
//                     style: const TextStyle(
//                       fontSize: 12.0,
//                       color: Colors.black54,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//             ],
//             if (attachment != null)
//               VoiceNotePlayer(attachment: attachment)
//             else
//               Text(
//                 message.text ?? '',
//                 style: TextStyle(
//                   fontSize: 14.0,
//                   color: isMyMessage ? Colors.white : Colors.black,
//                 ),
//               ),
//             const SizedBox(height: 4),
//             Text(
//               message.text ?? '',
//               style: TextStyle(
//                 fontSize: 14.0,
//                 color: isMyMessage ? Colors.white : Colors.black,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               DateFormat('hh:mm a').format(message.createdAt.toLocal()),
//               style: TextStyle(
//                 fontSize: 10.0,
//                 color: isMyMessage ? Colors.white70 : Colors.black54,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   onPressed: () => onReaction(message.id),
//                   icon: const Icon(Icons.thumb_up, size: 16),
//                 ),
//                 IconButton(
//                   onPressed: () => onThreadReply(message),
//                   icon: const Icon(Icons.reply, size: 16),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class VoiceNotePlayer extends StatelessWidget {
//   final Attachment attachment;

//   const VoiceNotePlayer({super.key, required this.attachment});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(Icons.audiotrack, color: Colors.black54),
//         Text(
//           'Voice Note: ${basename(attachment.file!.path!)}',
//           style: const TextStyle(
//             fontSize: 14.0,
//             color: Colors.black,
//           ),
//         ),
//         // Add your audio player widget here
//       ],
//     );
//   }
// }
