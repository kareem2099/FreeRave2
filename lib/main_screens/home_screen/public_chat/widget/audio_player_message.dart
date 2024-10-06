import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freerave/main_screens/home_screen/public_chat/widget/audio_loading_message.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerMessage extends StatefulWidget {
  const AudioPlayerMessage({
    Key? key,
    required this.source,
    required this.id,
  }) : super(key: key);

  final AudioSource source;
  final String id;

  @override
  AudioPlayerMessageState createState() => AudioPlayerMessageState();
}

class AudioPlayerMessageState extends State<AudioPlayerMessage> {
  final _audioPlayer = AudioPlayer();
  late StreamSubscription<PlayerState> _playerStateChangedSubscription;

  late Future<Duration?> futureDuration;

  @override
  void initState() {
    super.initState();

    _playerStateChangedSubscription =
        _audioPlayer.playerStateStream.listen(playerStateListener);

    futureDuration = _audioPlayer.setAudioSource(widget.source);
  }

  void playerStateListener(PlayerState state) async {
    if (state.processingState == ProcessingState.completed) {
      await reset();
    }
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Duration?>(
      future: futureDuration,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _controlButtons(),
              Expanded(
                child: _slider(snapshot.data),
              ),
            ],
          );
        }
        return const AudioLoadingMessage();
      },
    );
  }

  Widget _controlButtons() {
    return StreamBuilder<bool>(
      stream: _audioPlayer.playingStream,
      builder: (context, _) {
        final color =
            _audioPlayer.playerState.playing ? Colors.red : Colors.blue;
        final icon =
            _audioPlayer.playerState.playing ? Icons.pause : Icons.play_arrow;
        return Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_audioPlayer.playerState.playing) {
                  pause();
                } else {
                  play();
                }
              },
              child: Icon(icon, color: color, size: 30),
            ),
            DropdownButton<double>(
              value: _audioPlayer.speed,
              items: const [
                DropdownMenuItem(value: 0.5, child: Text("0.5x")),
                DropdownMenuItem(value: 1.0, child: Text("1x")),
                DropdownMenuItem(value: 1.5, child: Text("1.5x")),
                DropdownMenuItem(value: 2.0, child: Text("2x")),
              ],
              onChanged: (newSpeed) {
                _audioPlayer.setSpeed(newSpeed!);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _slider(Duration? duration) {
    return StreamBuilder<Duration>(
      stream: _audioPlayer.positionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && duration != null) {
          return CupertinoSlider(
            value: snapshot.data!.inMicroseconds / duration.inMicroseconds,
            onChanged: (val) {
              _audioPlayer.seek(duration * val);
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print("Failed to play audio: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Playback Error'),
          content: const Text('Unable to play the audio file.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }


  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    return _audioPlayer.seek(const Duration(milliseconds: 0));
  }
}
