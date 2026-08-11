import 'package:flutter/foundation.dart';

import '../models/language.dart';
import '../models/translation.dart';
import '../providers/translation_provider.dart';
import '../services/speech/speech_service.dart';
import '../services/tts/tts_service.dart';

class ConversationEngine {
  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();

  final _translator = TranslationProvider.getTranslator();

  bool _running = false;
  Future<void>? _activeSpeak;

  bool get isRunning => _running;

  // ============================================================
  // INICIALIZAR
  // ============================================================

  Future<bool> initialize() async {
    final speechReady =
        await _speechService.initialize();

    await _ttsService.initialize();

    return speechReady;
  }

  // ============================================================
  // INICIAR MOTOR
  // ============================================================

  Future<void> start() async {
    _running = true;
  }

  // ============================================================
  // EMPEZAR ESCUCHA
  // ============================================================

  Future<bool> startListening({
    required Language source,
  }) async {
    if (!_running) {
      await start();
    }

    debugPrint(
      'NEXA ENGINE: START LISTENING '
      '${source.speechLocale}',
    );

    await _ttsService.stop();

    return await _speechService.startListening(
      localeId: source.speechLocale,
    );
  }

  // ============================================================
  // DETENER ESCUCHA
  // ============================================================

  Future<String?> stopListening() async {
    debugPrint(
      'NEXA ENGINE: STOP LISTENING',
    );

    return await _speechService.stopListening();
  }

  // ============================================================
  // TRADUCIR Y REPRODUCIR
  // ============================================================

  Future<Translation?> translateAndSpeak({
    required String originalText,
    required Language source,
    required Language target,
    required String speakerId,
    bool speak = true,
  }) async {
    final text = originalText.trim();

    if (text.isEmpty) {
      return null;
    }

    debugPrint(
      'NEXA ENGINE: TRANSLATING "$text"',
    );

    _running = true;

    try {
      final translatedText =
          await _translator.translate(
        text: text,
        sourceLanguage: source.codigo,
        targetLanguage: target.codigo,
      );

      debugPrint(
        'NEXA ENGINE: TRANSLATED '
        '"$translatedText"',
      );

      if (!_running) {
        return null;
      }

      if (speak) {
        debugPrint(
          'NEXA ENGINE: SPEAKING '
          '"$translatedText"',
        );

        // Reproducimos la voz sin bloquear: así el texto
        // aparece en pantalla mientras se escucha la frase.
        _activeSpeak = _ttsService
            .speak(
          text: translatedText,
          language: target.ttsLocale,
        )
            .catchError((Object e) {
          debugPrint('NEXA ENGINE SPEAK ERROR: $e');
        });
      } else {
        _activeSpeak = null;
      }

      return Translation(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        speakerId: speakerId,
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: source.codigo,
        targetLanguage: target.codigo,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint(
        'NEXA ENGINE ERROR: $e',
      );

      return null;
    }
  }

  // ============================================================
  // ESPERAR A QUE TERMINE LA VOZ
  // ============================================================

  Future<void> waitForSpeech() async {
    final active = _activeSpeak;

    if (active == null) {
      return;
    }

    try {
      await active;
    } catch (e) {
      debugPrint('NEXA ENGINE WAIT SPEECH ERROR: $e');
    }

    _activeSpeak = null;
  }

  // ============================================================
  // PROCESO AUTOMÁTICO
  // ============================================================
  //
  // Este método se mantiene para la conversación continua.
  // IMPORTANTE: utiliza startListening/stopListening.
  //

  Future<Translation?> process({
    required Language source,
    required Language target,
    required String speakerId,
  }) async {
    if (!_running) {
      await start();
    }

    final started =
        await startListening(
      source: source,
    );

    if (!started) {
      return null;
    }

    // Esperamos a que speech_to_text termine.
    //
    // El stopListening se utiliza cuando se detiene
    // la escucha desde la interfaz.
    //
    // Para evitar bloquear indefinidamente, esperamos
    // hasta que el reconocimiento deje de estar activo.

    while (_speechService.isListening && _running) {
      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
    }

    if (!_running) {
      return null;
    }

    final originalText =
        await stopListening();

    if (originalText == null ||
        originalText.trim().isEmpty) {
      return null;
    }

    return await translateAndSpeak(
      originalText: originalText,
      source: source,
      target: target,
      speakerId: speakerId,
    );
  }

  // ============================================================
  // HABLAR
  // ============================================================

  Future<void> speak({
    required String text,
    required String language,
  }) async {
    await _ttsService.speak(
      text: text,
      language: language,
    );
  }

  // ============================================================
  // DETENER
  // ============================================================

  Future<void> stop() async {
    _running = false;

    _activeSpeak = null;

    await _speechService.stopListening();

    await _ttsService.stop();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    await stop();
  }
}