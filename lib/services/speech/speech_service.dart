import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool _initialized = false;
  String _lastWords = '';
  bool _lastResultFinal = false;

  bool get isInitialized => _initialized;

  bool get isListening => _speech.isListening;

  // ============================================================
  // INICIALIZAR
  // ============================================================

  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    _initialized = await _speech.initialize(
      onStatus: (status) {
        debugPrint('NEXA SPEECH STATUS: $status');
      },
      onError: (error) {
        debugPrint(
          'NEXA SPEECH ERROR: '
          '${error.errorMsg} '
          'permanent=${error.permanent}',
        );
      },
      debugLogging: true,
    );

    debugPrint(
      'NEXA SPEECH INITIALIZED: $_initialized',
    );

    return _initialized;
  }

  // ============================================================
  // EMPEZAR A ESCUCHAR
  // ============================================================

  Future<bool> startListening({
    required String localeId,
  }) async {
    if (!await initialize()) {
      debugPrint('NEXA SPEECH: INITIALIZATION FAILED');
      return false;
    }

    if (_speech.isListening) {
      debugPrint('NEXA SPEECH: ALREADY LISTENING');
      return true;
    }

    _lastWords = '';
    _lastResultFinal = false;

    debugPrint(
      'NEXA SPEECH: START LISTENING '
      'locale=$localeId',
    );

    try {
      var started = await _startRecognizer(localeId);

      // Primer intento fallido que no sea por iniciativa del usuario:
      // reintenta una vez (a veces el motor no arranca a la primera).
      if (!started) {
        debugPrint('NEXA SPEECH: RETRY START LISTENING');
        await Future<void>.delayed(
          const Duration(milliseconds: 400),
        );

        started = await _startRecognizer(localeId);
      }

      debugPrint(
        'NEXA SPEECH: LISTEN STARTED '
        'isListening=${_speech.isListening}',
      );

      return started || _speech.isListening;
    } catch (e) {
      debugPrint(
        'NEXA SPEECH START ERROR: $e',
      );

      return false;
    }
  }

  Future<bool> _startRecognizer(String localeId) async {
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
        pauseFor: const Duration(seconds: 10),
        enableHapticFeedback: true,
      ),
      onResult: (result) {
        final words = result.recognizedWords.trim();

        debugPrint(
          'NEXA SPEECH RESULT: '
          '"$words" '
          'final=${result.finalResult}',
        );

        if (words.isNotEmpty) {
          _lastWords = words;
        }

        _lastResultFinal = result.finalResult;
      },
    );

    return _speech.isListening;
  }

  // ============================================================
  // DETENER ESCUCHA
  // ============================================================

  Future<String?> stopListening() async {
    debugPrint('NEXA SPEECH: STOP REQUESTED');

    if (_speech.isListening) {
      try {
        await _speech.stop();
      } catch (e) {
        debugPrint(
          'NEXA SPEECH STOP ERROR: $e',
        );
      }

      // El callback del resultado final puede llegar justo después
      // de stop(). Esperamos hasta 800 ms a que llegue para no
      // perder las últimas palabras de la frase.
      final stopwatch = Stopwatch()..start();

      while (!_lastResultFinal &&
          stopwatch.elapsedMilliseconds < 800) {
        await Future<void>.delayed(
          const Duration(milliseconds: 50),
        );
      }
    }

    final text = _lastWords.trim();

    debugPrint(
      'NEXA SPEECH: STOPPED text="$text"',
    );

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  // ============================================================
  // CANCELAR
  // ============================================================

  Future<void> cancelListening() async {
    debugPrint('NEXA SPEECH: CANCEL');

    if (_speech.isListening) {
      await _speech.cancel();
    }

    _lastWords = '';
    _lastResultFinal = false;
  }

  // ============================================================
  // IDIOMAS
  // ============================================================

  Future<List<LocaleName>> getAvailableLanguages() async {
    if (!await initialize()) {
      return [];
    }

    return _speech.locales();
  }

  // ============================================================
  // IDIOMA DEL SISTEMA
  // ============================================================

  Future<String?> getSystemLanguage() async {
    if (!await initialize()) {
      return null;
    }

    final locale = await _speech.systemLocale();

    return locale?.localeId;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }

    _lastWords = '';
    _lastResultFinal = false;
  }
}