import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _text = '';
  String _error = '';

  // Initialize the speech-to-text service
  Future<void> initSpeech() async {
    try {
      await _speech.initialize();
    } catch (e) {
      _error = 'Error initializing speech recognition: ${e.toString()}';
    }
  }

  // Start listening to the user's speech
  void startListening(Function(String) onResult) {
    if (!_speech.isAvailable) {
      _error = 'Speech recognition is not available';
      return;
    }
    try {
      _speech.listen(
        onResult: (result) {
          _text = result.recognizedWords;
          onResult(_text);
        },
      );
      _isListening = true;
    } catch (e) {
      _error = 'Error starting speech recognition: ${e.toString()}';
    }
  }

  // Stop listening
  void stopListening() {
    if (!_isListening) return;
    try {
      _speech.stop();
      _isListening = false;
    } catch (e) {
      _error = 'Error stopping speech recognition: ${e.toString()}';
    }
  }

  bool get isListening => _isListening;
  String get text => _text;
  String get error => _error;
}
