import '../services/translation/google_mlkit_translation_service.dart';
import '../services/translation/translation_service.dart';

class TranslationProvider {
  static TranslationService getTranslator() {
    return GoogleMlKitTranslationService();
  }
}