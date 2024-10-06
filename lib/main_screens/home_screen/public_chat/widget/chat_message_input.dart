import 'dart:io';
import 'package:freerave/main_screens/home_screen/public_chat/widget/record_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../cubit/stream_chat_cubit.dart';
import 'package:path/path.dart' as pathhe;

class ChatMessageInput extends StatelessWidget {
  final Channel channel;
  final Function(String)? onTyping;

  const ChatMessageInput({super.key, required this.channel, this.onTyping});

  @override
  Widget build(BuildContext context) {
    Future<void> requestStoragePermission() async {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }

    Future<String> saveRecordingLocally(String originalPath) async {
      // Request storage permission
      await requestStoragePermission();

      // Get the FreeRave folder in external storage
      Directory? externalDir = await getExternalStorageDirectory();
      String freeRavePath =
          pathhe.join(externalDir!.path, 'FreeRave', 'voice messages');

      // Create directory if it doesn't exist
      Directory(freeRavePath)
          .createSync(recursive: true); // Correct variable name

      // Create a new path in the directory
      String newPath = pathhe.join(freeRavePath,
          pathhe.basename(originalPath)); // Use path.basename properly
      File file = File(originalPath);
      File newFile = await file.copy(newPath); // Copy file to the new path
      return newFile.path;
    }

    void recordingFinishedCallback(String path) async {
      try {
        // Log the start of the process
        print('Recording finished. Path: $path');
        // Save the file locally
        String localPath = await saveRecordingLocally(path);
        print('File saved locally at: $localPath');
        File file = File(localPath);
        final fileSize = await file.length();
        print('File size: $fileSize bytes');

        // Define a reference for Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        final audioRef =
            storageRef.child('audio/${pathhe.basename(localPath)}');
        // Log before upload
        print('Uploading file to Firebase Storage...');

        // Upload the file
        final uploadTask = audioRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => null);
        // Log after upload
        print('File uploaded successfully! Getting download URL...');
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('Download URL: $downloadUrl');

        if (context.mounted) {
          StreamChannel.of(context).channel.sendMessage(
                Message(
                  attachments: [
                    Attachment(
                      type: 'voicenote',
                      assetUrl: downloadUrl,
                      file: AttachmentFile(
                        size: fileSize,
                        path: localPath,
                      ),
                    )
                  ],
                ),
              );
          print('Message sent with audio attachment.');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        children: [
          Expanded(
            child: StreamMessageInput(
              allowedAttachmentPickerTypes: const [AttachmentPickerType.files],
              actionsBuilder: (context, defaultActions) {
                return [
                  ...defaultActions, // Include the default attachment actions
                ];
              },
              onMessageSent: (Message message) {
                // context
                //     .read<StreamChatCubit>()
                //     .sendMessage(channel, message.text!);
                print('Message sent: ${message.text}');
              },
              sendButtonLocation: SendButtonLocation.inside,
              disableAttachments: false,
              actionsLocation: ActionsLocation.left,
              autoCorrect: true,
              showCommandsButton: true,
              enableActionAnimation: true,
            ),
          ),
          RecordButton(
            recordingFinishedCallback: recordingFinishedCallback,
          ),

        ],
      ),
    );
  }
}
