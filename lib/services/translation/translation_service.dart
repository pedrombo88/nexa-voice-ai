abstract class TranslationService {
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });
}