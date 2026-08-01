import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool _initialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_initialized) return true;

    _initialized = await _speech.initialize();

    return _initialized;
  }

  Future<String?> listen({
    required String localeId,
  }) async {
    if (!_initialized) {
      final ok = await initialize();

      if (!ok) {
        return null;
      }
    }

    if (_isListening) {
      return null;
    }

    final completer = Completer<String?>();

    _isListening = true;

    await _speech.listen(
      localeId: localeId,
      listenMode: ListenMode.confirmation,
      onResult: (result) async {
        if (!result.finalResult) return;

        await _speech.stop();

        _isListening = false;

        if (!completer.isCompleted) {
          completer.complete(result.recognizedWords);
        }
      },
    );

    return completer.future;
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speech.stop();

    _isListening = false;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();

    _isListening = false;
  }

  Future<List<LocaleName>> getAvailableLanguages() async {
    if (!_initialized) {
      await initialize();
    }

    return _speech.locales();
  }

  Future<String?> getSystemLanguage() async {
    if (!_initialized) {
      await initialize();
    }

    final locale = await _speech.systemLocale();

    return locale?.localeId;
  }
}