import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        print("🎤 Estado: $status");
      },
      onError: (error) {
        print("❌ Error: ${error.errorMsg}");
      },
    );

    print("Inicializado: $_isInitialized");

    return _isInitialized;
  }

  Future<void> startListening({
    required String localeId,
    required Function(String text) onResult,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();

      if (!ok) {
        print("No se pudo inicializar SpeechToText");
        return;
      }
    }

    if (_isListening) return;

    _isListening = true;

    await _speech.listen(
      localeId: localeId,
      listenMode: ListenMode.confirmation,
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
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
    if (!_isInitialized) {
      await initialize();
    }

    return await _speech.locales();
  }

  Future<String?> getSystemLanguage() async {
    if (!_isInitialized) {
      await initialize();
    }

    final locale = await _speech.systemLocale();

    return locale?.localeId;
  }
}