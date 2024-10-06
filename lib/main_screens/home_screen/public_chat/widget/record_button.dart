import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

typedef RecordCallback = void Function(String);

class RecordButton extends StatefulWidget {
  final RecordCallback recordingFinishedCallback;

  const RecordButton({
    Key? key,
    required this.recordingFinishedCallback,
  }) : super(key: key);

  @override
  RecordButtonState createState() => RecordButtonState();
}

class RecordButtonState extends State<RecordButton> {
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  late String _filePath;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Check for microphone permissions
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
      if (!status.isGranted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Denied'),
            content: const Text(
                'Microphone permission is required to record audio.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ok'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getExternalStorageDirectory();
      final freeRaveDir = Directory('${directory!.path}/FreeRave/voices_chat');
      if (!freeRaveDir.existsSync()) {
        freeRaveDir.createSync(recursive: true);
      }

      _filePath =
          '${freeRaveDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(),
        path: _filePath, // Save recording to this path
      );

      setState(() {
        _isRecording = true;
      });

      print('Recording started...');
    } else {
      print('Recording permission not granted.');
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      print('Recording stopped, file saved at $path');
      widget.recordingFinishedCallback(path);
    } else {
      print('Recording failed.');
    }
  }

  Widget buildRecordingIndicator() {
    return _isRecording
        ? const Row(
            children: [
              Icon(Icons.mic, color: Colors.red),
              SizedBox(width: 8), // Optional spacing between icon and text
              Text(
                'Recording...',
                style: TextStyle(color: Colors.red),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final color = _isRecording ? Colors.red.withOpacity(0.3) : Colors.blue;
    final icon = _isRecording ? Icons.stop : Icons.mic;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _isRecording ? _stopRecording() : _startRecording();
          },
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
        buildRecordingIndicator(),
      ],
    );
  }
}
