import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

typedef RecordCallback = void Function(String);

class RecordButton extends StatefulWidget {
  const RecordButton({
    Key? key,
    required this.recordingFinishedCallback,
  }) : super(key: key);

  final RecordCallback recordingFinishedCallback;

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isRecording = false;
  final _audioRecorder = AudioRecorder();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Get external storage directory
        final directory = await getExternalStorageDirectory();
        final freeRaveDir =
            Directory('${directory!.path}/FreeRave/voices chat');

        // Ensure directory exists
        if (!freeRaveDir.existsSync()) {
          freeRaveDir.createSync(recursive: true);
        }

        final path = '${freeRaveDir.path}/myfile.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();

    // Call the recording finished callback with the file path
    widget.recordingFinishedCallback(path!);

    setState(() => _isRecording = false);

    // Upload the file to Firebase Storage
    await _uploadToFirebase(path);
  }

  Future<void> _uploadToFirebase(String path) async {
    try {
      File file = File(path);
      if (await file.exists()) {
        // Create a reference to Firebase Storage
        final storageRef = _firebaseStorage
            .ref()
            .child('voice_messages/${file.uri.pathSegments.last}');

        // Upload the file
        await storageRef.putFile(file);

        // Optionally, get the download URL
        final downloadUrl = await storageRef.getDownloadURL();
        print('File uploaded. Download URL: $downloadUrl');
      }
    } catch (e) {
      print('Failed to upload file to Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color? color;
    if (_isRecording) {
      icon = Icons.stop;
      color = Colors.red.withOpacity(0.3);
    } else {
      color = StreamChatTheme.of(context).primaryIconTheme.color;
      icon = Icons.mic;
    }
    return GestureDetector(
      onTap: () {
        _isRecording ? _stop() : _start();
      },
      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}
