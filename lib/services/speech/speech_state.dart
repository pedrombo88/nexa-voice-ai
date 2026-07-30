class SpeechState {
  final bool isInitialized;
  final bool isListening;
  final String recognizedText;
  final String localeId;
  final String? error;

  const SpeechState({
    this.isInitialized = false,
    this.isListening = false,
    this.recognizedText = '',
    this.localeId = 'es_ES',
    this.error,
  });

  SpeechState copyWith({
    bool? isInitialized,
    bool? isListening,
    String? recognizedText,
    String? localeId,
    String? error,
  }) {
    return SpeechState(
      isInitialized: isInitialized ?? this.isInitialized,
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      localeId: localeId ?? this.localeId,
      error: error,
    );
  }

  @override
  String toString() {
    return '''
SpeechState(
  isInitialized: $isInitialized,
  isListening: $isListening,
  localeId: $localeId,
  recognizedText: "$recognizedText",
  error: $error
)
''';
  }
}