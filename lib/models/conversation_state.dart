import 'conversation_mode.dart';
import 'translation.dart';

class ConversationState {
  final bool isListening;
  final bool isTranslating;
  final bool isSpeaking;

  final ConversationMode? currentSpeaker;

  final List<Translation> history;

  const ConversationState({
    this.isListening = false,
    this.isTranslating = false,
    this.isSpeaking = false,
    this.currentSpeaker,
    this.history = const [],
  });

  bool get isIdle =>
      !isListening &&
      !isTranslating &&
      !isSpeaking;

  static const Object _unset = Object();

  ConversationState copyWith({
    bool? isListening,
    bool? isTranslating,
    bool? isSpeaking,
    Object? currentSpeaker = _unset,
    List<Translation>? history,
  }) {
    return ConversationState(
      isListening: isListening ?? this.isListening,
      isTranslating: isTranslating ?? this.isTranslating,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentSpeaker: currentSpeaker == _unset
          ? this.currentSpeaker
          : currentSpeaker as ConversationMode?,
      history: history ?? this.history,
    );
  }
}