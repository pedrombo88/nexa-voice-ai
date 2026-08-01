import 'package:flutter/foundation.dart';

import '../models/conversation_mode.dart';
import '../models/conversation_state.dart';
import '../models/translation.dart';
import '../widgets/conversation/listening_indicator.dart';

class ConversationManager extends ChangeNotifier {
  ConversationState _state = const ConversationState();

  ConversationState get state => _state;

  bool get isListening => _state.isListening;

  bool get isTranslating => _state.isTranslating;

  bool get isSpeaking => _state.isSpeaking;

  ConversationMode? get currentSpeaker => _state.currentSpeaker;

  List<Translation> get history => _state.history;

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

  void startListening(ConversationMode speaker) {
    _state = _state.copyWith(
      isListening: true,
      isSpeaking: false,
      isTranslating: false,
      currentSpeaker: speaker,
    );

    notifyListeners();
  }

  void translating() {
    _state = _state.copyWith(
      isListening: false,
      isTranslating: true,
      isSpeaking: false,
    );

    notifyListeners();
  }

  void speaking() {
    _state = _state.copyWith(
      isListening: false,
      isTranslating: false,
      isSpeaking: true,
    );

    notifyListeners();
  }

  void idle() {
    _state = _state.copyWith(
      isListening: false,
      isTranslating: false,
      isSpeaking: false,
    );

    notifyListeners();
  }

  void stopListening() {
    _state = _state.copyWith(
      isListening: false,
      isTranslating: false,
      isSpeaking: false,
      currentSpeaker: null,
    );

    notifyListeners();
  }

  void switchSpeaker() {
    final nextSpeaker =
        _state.currentSpeaker == ConversationMode.person1
            ? ConversationMode.person2
            : ConversationMode.person1;

    _state = _state.copyWith(
      currentSpeaker: nextSpeaker,
    );

    notifyListeners();
  }

  void addTranslation(Translation translation) {
    final updatedHistory = List<Translation>.from(_state.history)
      ..add(translation);

    _state = _state.copyWith(
      history: updatedHistory,
    );

    notifyListeners();
  }

  void clearHistory() {
    _state = _state.copyWith(
      history: [],
    );

    notifyListeners();
  }
}
