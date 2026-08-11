import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/call_participant.dart';
import '../models/call_turn.dart';
import '../models/language.dart';
import '../providers/translation_provider.dart';
import '../services/call/call_relay.dart';
import '../services/call/call_relay_factory.dart';
import '../services/speech/speech_service.dart';
import '../services/translation/translation_service.dart';
import '../services/tts/tts_service.dart';

enum CallConnectionState {
  idle,
  creating,
  joining,
  connected,
  ended,
  error,
}

/// Gestiona una llamada traducida entre dos participantes.
///
/// Flujo de un turno:
///  1. El usuario mantiene pulsado el micrófono (STT captura su voz).
///  2. Al soltar, se traduce el texto a la lengua del otro participante.
///  3. El turno se publica en el relay.
///  4. El otro teléfono lo recibe y reproduce la traducción por TTS.
class CallManager extends ChangeNotifier {
  final SpeechService _speech = SpeechService();
  final TtsService _tts = TtsService();
  final TranslationService _translator = TranslationProvider.getTranslator();

  CallRelay? _relay;

  CallConnectionState _state = CallConnectionState.idle;
  String? _error;
  String _sessionId = '';
  String _myId = '';
  String _myName = '';
  Language _myLanguage = idiomasDisponibles.first;
  CallParticipant? _peer;

  final List<CallTurn> _history = [];

  bool _listening = false;
  bool _translating = false;
  bool _speaking = false;
  bool _disposed = false;

  StreamSubscription<CallTurn>? _turnSub;
  StreamSubscription<CallParticipant?>? _peerSub;

  // ============================================================
  // GETTERS
  // ============================================================

  CallConnectionState get state => _state;
  String? get error => _error;
  String get sessionId => _sessionId;
  String get myId => _myId;
  String get myName => _myName;
  Language get myLanguage => _myLanguage;

  CallParticipant? get peer => _peer;
  String get peerName => _peer?.name ?? 'Esperando...';

  bool get isConnected => _state == CallConnectionState.connected;
  bool get isIdle => _state == CallConnectionState.idle;
  bool get isBusy =>
      _state == CallConnectionState.creating ||
      _state == CallConnectionState.joining;

  bool get isListening => _listening;
  bool get isTranslating => _translating;
  bool get isSpeaking => _speaking;

  List<CallTurn> get history => List.unmodifiable(_history);

  // ============================================================
  // CREAR LLAMADA
  // ============================================================

  Future<void> startCall({
    required String myName,
    required Language myLanguage,
  }) async {
    if (isBusy) {
      return;
    }

    _state = CallConnectionState.creating;
    _myName = myName;
    _myLanguage = myLanguage;
    notifyListeners();

    try {
      final speechReady = await _speech.initialize();

      if (!speechReady) {
        _fail(
          'No se pudo acceder al micrófono. '
          'Revisa el permiso en los Ajustes del teléfono.',
        );
        return;
      }

      await _tts.initialize();

      final relay = CallRelayFactory.create();
      _relay = relay;
      _subscribeRelay();

      _myId = _newId('yo');

      _sessionId = await relay.createSession(
        me: CallParticipant(
          id: _myId,
          name: _myName,
          languageCode: _myLanguage.codigo,
        ),
      );

      _state = CallConnectionState.connected;
      notifyListeners();
    } catch (e) {
      _fail('No se pudo crear la llamada: $e');
    }
  }

  // ============================================================
  // UNIRSE A LLAMADA
  // ============================================================

  Future<void> joinCall({
    required String sessionId,
    required String myName,
    required Language myLanguage,
  }) async {
    if (isBusy) {
      return;
    }

    _state = CallConnectionState.joining;
    _myName = myName;
    _myLanguage = myLanguage;
    notifyListeners();

    try {
      final speechReady = await _speech.initialize();

      if (!speechReady) {
        _fail(
          'No se pudo acceder al micrófono. '
          'Revisa el permiso en los Ajustes del teléfono.',
        );
        return;
      }

      await _tts.initialize();

      final relay = CallRelayFactory.create();
      _relay = relay;
      _subscribeRelay();

      _myId = _newId('yo');

      await relay.joinSession(
        sessionId: sessionId,
        me: CallParticipant(
          id: _myId,
          name: _myName,
          languageCode: _myLanguage.codigo,
        ),
      );

      _sessionId = sessionId;

      _state = CallConnectionState.connected;
      notifyListeners();
    } catch (e) {
      _fail('No se pudo unir a la llamada: $e');
    }
  }

  // ============================================================
  // TURNO DE VOZ (PUSH TO TALK)
  // ============================================================

  Future<void> startTurn() async {
    if (!isConnected || _listening || _translating) {
      return;
    }

    _listening = true;
    notifyListeners();

    final started = await _speech.startListening(
      localeId: _myLanguage.speechLocale,
    );

    if (!started) {
      _listening = false;
      notifyListeners();
    }
  }

  Future<void> finishTurn() async {
    if (!_listening) {
      return;
    }

    _listening = false;
    _translating = true;
    notifyListeners();

    final originalText = await _speech.stopListening();

    if (originalText == null || originalText.trim().isEmpty) {
      _translating = false;
      notifyListeners();
      return;
    }

    final peerLanguage = _peer?.languageCode;

    if (peerLanguage == null || peerLanguage == _myLanguage.codigo) {
      _translating = false;
      notifyListeners();
      return;
    }

    try {
      final translated = await _translator.translate(
        text: originalText,
        sourceLanguage: _myLanguage.codigo,
        targetLanguage: peerLanguage,
      );

      final turn = CallTurn(
        id: _newId('turn'),
        senderId: _myId,
        senderName: _myName,
        sourceLanguage: _myLanguage.codigo,
        targetLanguage: peerLanguage,
        originalText: originalText.trim(),
        translatedText: translated.trim(),
        timestamp: DateTime.now(),
      );

      _history.add(turn);

      await _relay?.sendTurn(turn);

      notifyListeners();
    } catch (e) {
      debugPrint('NEXA CALL TURN ERROR: $e');
    } finally {
      _translating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // TURNO RECIBIDO
  // ============================================================

  Future<void> _onRemoteTurn(CallTurn turn) async {
    _history.add(turn);
    _speaking = true;
    notifyListeners();

    try {
      await _tts.speak(
        text: turn.translatedText,
        language: _myLanguage.ttsLocale,
      );
    } catch (e) {
      debugPrint('NEXA CALL TTS ERROR: $e');
    } finally {
      _speaking = false;
      notifyListeners();
    }
  }

  void _onPeer(CallParticipant? peer) {
    _peer = peer;
    notifyListeners();
  }

  // ============================================================
  // SUSCRIPCIONES
  // ============================================================

  void _subscribeRelay() {
    final relay = _relay;

    if (relay == null) {
      return;
    }

    _turnSub = relay.onTurn.listen(_onRemoteTurn);
    _peerSub = relay.onPeer.listen(_onPeer);
  }

  // ============================================================
  // COLGAR
  // ============================================================

  Future<void> endCall() async {
    _state = CallConnectionState.ended;
    notifyListeners();

    await _turnSub?.cancel();
    await _peerSub?.cancel();

    await _relay?.leave();
  }

  // ============================================================
  // LIMPIAR HISTORIAL
  // ============================================================

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  void _fail(String message) {
    _state = CallConnectionState.error;
    _error = message;
    notifyListeners();
  }

  String _newId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _disposed = true;

    _turnSub?.cancel();
    _peerSub?.cancel();

    _relay?.dispose();
    _speech.dispose();
    _tts.stop();

    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) {
      return;
    }
    super.notifyListeners();
  }
}
