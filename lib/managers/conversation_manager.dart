import 'package:flutter/foundation.dart';

import '../engine/conversation_engine.dart';
import '../models/conversation_mode.dart';
import '../models/conversation_state.dart';
import '../models/language.dart';
import '../models/translation.dart';
import '../widgets/conversation/listening_indicator.dart';

class ConversationManager extends ChangeNotifier {
  final ConversationEngine _engine =
      ConversationEngine();

  ConversationState _state =
      const ConversationState();

  bool _running = false;
  bool _processing = false;

  ConversationState get state => _state;

  bool get isListening =>
      _state.isListening;

  bool get isTranslating =>
      _state.isTranslating;

  bool get isSpeaking =>
      _state.isSpeaking;

  bool get isIdle =>
      _state.isIdle;

  bool get isRunning =>
      _running;

  bool get isProcessing =>
      _processing;

  ConversationMode? get currentSpeaker =>
      _state.currentSpeaker;

  List<Translation> get history =>
      List.unmodifiable(_state.history);

  // ============================================================
  // ESTADO DE ESCUCHA
  // ============================================================

  ListeningState get listeningState {
    if (_state.isSpeaking) {
      return ListeningState.speaking;
    }

    if (_state.isTranslating) {
      return ListeningState.translating;
    }

    if (_state.isListening) {
      return ListeningState.listening;
    }

    return ListeningState.idle;
  }

  // ============================================================
  // INICIALIZAR
  // ============================================================

  Future<bool> initialize() async {
    return await _engine.initialize();
  }

  // ============================================================
  // EMPEZAR A ESCUCHAR
  // ============================================================

  Future<void> startListening({
    required ConversationMode speaker,
    required Language source,
  }) async {
    if (_processing) {
      return;
    }

    if (_state.isListening) {
      return;
    }

    _running = true;

    _state = _state.copyWith(
      isListening: true,
      isTranslating: false,
      isSpeaking: false,
      currentSpeaker: speaker,
    );

    notifyListeners();

    debugPrint(
      'NEXA MANAGER: START LISTENING '
      'speaker=$speaker',
    );

    final started =
        await _engine.startListening(
      source: source,
    );

    if (!started) {
      _state = _state.copyWith(
        isListening: false,
        isTranslating: false,
        isSpeaking: false,
        currentSpeaker: null,
      );

      notifyListeners();
    }
  }

  // ============================================================
  // PROCESAR AL SOLTAR EL MICRÓFONO
  // ============================================================

  Future<void> processConversation({
    required Language source,
    required Language target,
    required String speakerId,
  }) async {
    if (_processing) {
      return;
    }

    if (!_state.isListening) {
      return;
    }

    _processing = true;

    _state = _state.copyWith(
      isListening: false,
      isTranslating: true,
      isSpeaking: false,
    );

    notifyListeners();

    try {
      debugPrint(
        'NEXA MANAGER: STOP LISTENING',
      );

      final originalText =
          await _engine.stopListening();

      if (originalText == null ||
          originalText.trim().isEmpty) {
        debugPrint(
          'NEXA MANAGER: NO TEXT',
        );

        _state = _state.copyWith(
          isListening: false,
          isTranslating: false,
          isSpeaking: false,
          currentSpeaker: null,
        );

        notifyListeners();

        return;
      }

      debugPrint(
        'NEXA MANAGER: TEXT="$originalText"',
      );

      final translation =
          await _engine.translateAndSpeak(
        originalText: originalText,
        source: source,
        target: target,
        speakerId: speakerId,
      );

      if (translation == null) {
        _state = _state.copyWith(
          isListening: false,
          isTranslating: false,
          isSpeaking: false,
          currentSpeaker: null,
        );

        notifyListeners();

        return;
      }

      addTranslation(translation);

      _state = _state.copyWith(
        isListening: false,
        isTranslating: false,
        isSpeaking: true,
        currentSpeaker: null,
      );

      notifyListeners();

      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      _state = _state.copyWith(
        isListening: false,
        isTranslating: false,
        isSpeaking: false,
        currentSpeaker: null,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'NEXA MANAGER PROCESS ERROR: $e',
      );

      _state = _state.copyWith(
        isListening: false,
        isTranslating: false,
        isSpeaking: false,
        currentSpeaker: null,
      );

      notifyListeners();
    } finally {
      _processing = false;
    }
  }

  // ============================================================
  // AÑADIR TRADUCCIÓN
  // ============================================================

  void addTranslation(
    Translation translation,
  ) {
    final updatedHistory =
        List<Translation>.from(
      _state.history,
    )..add(translation);

    _state = _state.copyWith(
      history: updatedHistory,
    );

    notifyListeners();
  }

  // ============================================================
  // DETENER
  // ============================================================

  Future<void> stopConversation() async {
    _running = false;
    _processing = false;

    await _engine.stop();

    _state = _state.copyWith(
      isListening: false,
      isTranslating: false,
      isSpeaking: false,
      currentSpeaker: null,
    );

    notifyListeners();
  }

  // ============================================================
  // LIMPIAR HISTORIAL
  // ============================================================

  void clearHistory() {
    _state = _state.copyWith(
      history: [],
    );

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _running = false;
    _processing = false;

    _engine.dispose();

    super.dispose();
  }
}