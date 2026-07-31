import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'translation_service.dart';

class GoogleMlKitTranslationService implements TranslationService {
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final source = TranslateLanguage.values.firstWhere(
      (l) => l.bcpCode == sourceLanguage,
    );

    final target = TranslateLanguage.values.firstWhere(
      (l) => l.bcpCode == targetLanguage,
    );

    // Descarga los modelos si no existen
    await _modelManager.downloadModel(source.bcpCode);
    await _modelManager.downloadModel(target.bcpCode);

    final translator = OnDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
    );

    final translated = await translator.translateText(text);

    await translator.close();

    return translated;
  }
}