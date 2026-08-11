import 'package:flutter/foundation.dart';

import 'translation_service.dart';

/// Traducción híbrida: intenta la nube primero y, si falla
/// (sin internet, sin permisos, etc.), usa Google ML Kit on-device.
class HybridTranslationService implements TranslationService {
  final TranslationService _cloud;
  final TranslationService _fallback;

  HybridTranslationService({
    required TranslationService cloud,
    required TranslationService fallback,
  })  : _cloud = cloud,
        _fallback = fallback;

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final result = await _cloud.translate(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      if (result.trim().isNotEmpty) {
        return result;
      }
    } catch (e) {
      debugPrint('NEXA HYBRID: CLOUD FAILED, fallback on-device. $e');
    }

    return _fallback.translate(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }
}