import 'package:flutter/foundation.dart';

import '../models/conversation_mode.dart';
import '../widgets/conversation/listening_indicator.dart';

class ConversationManager extends ChangeNotifier {
  ConversationMode? _currentSpeaker;

  ListeningState _state = ListeningState.idle;

  bool _isListening = false;

  bool get isListening => _isListening;

  ConversationMode? get currentSpeaker => _currentSpeaker;

  ListeningState get state => _state;

  void startListening(ConversationMode speaker) {
    _currentSpeaker = speaker;
    _isListening = true;
    _state = ListeningState.listening;

    notifyListeners();
  }

  void translating() {
    _state = ListeningState.translating;
    notifyListeners();
  }

  void speaking() {
    _state = ListeningState.speaking;
    notifyListeners();
  }

  void idle() {
    _state = ListeningState.idle;
    notifyListeners();
  }

  void stopListening() {
    _isListening = false;
    _currentSpeaker = null;
    _state = ListeningState.idle;

    notifyListeners();
  }

  void switchSpeaker() {
    if (_currentSpeaker == ConversationMode.person1) {
      _currentSpeaker = ConversationMode.person2;
    } else {
      _currentSpeaker = ConversationMode.person1;
    }

    notifyListeners();
  }
}