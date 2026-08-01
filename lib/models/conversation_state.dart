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

  ConversationState copyWith({
    bool? isListening,
    bool? isTranslating,
    bool? isSpeaking,
    ConversationMode? currentSpeaker,
    List<Translation>? history,
  }) {
    return ConversationState(
      isListening: isListening ?? this.isListening,
      isTranslating: isTranslating ?? this.isTranslating,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentSpeaker: currentSpeaker ?? this.currentSpeaker,
      history: history ?? this.history,
    );
  }
}