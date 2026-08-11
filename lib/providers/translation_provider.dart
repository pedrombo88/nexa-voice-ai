import '../config/app_config.dart';
import '../services/translation/cloud_translation_service.dart';
import '../services/translation/google_mlkit_translation_service.dart';
import '../services/translation/hybrid_translation_service.dart';
import '../services/translation/translation_service.dart';

class TranslationProvider {
  /// Traducción híbrida: nube (si hay internet) con respaldo on-device.
  static TranslationService getTranslator() {
    return HybridTranslationService(
      cloud: CloudTranslationService(),
      fallback: GoogleMlKitTranslationService(),
    );
  }

  static bool isCloudConfigured() {
    return AppConfig.cloudTranslationApiKey.isNotEmpty;
  }
}