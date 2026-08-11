import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'translation_service.dart';

class GoogleMlKitTranslationService
    implements TranslationService {
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return '';
    }

    debugPrint(
      'NEXA TRANSLATION: '
      'source=$sourceLanguage '
      'target=$targetLanguage '
      'text="$cleanText"',
    );

    try {
      // ============================================================
      // IDIOMA ORIGEN
      // ============================================================

      final source = TranslateLanguage.values.firstWhere(
        (language) =>
            language.bcpCode.toLowerCase() ==
            sourceLanguage.toLowerCase(),
        orElse: () {
          throw Exception(
            'Idioma origen no soportado: $sourceLanguage',
          );
        },
      );

      // ============================================================
      // IDIOMA DESTINO
      // ============================================================

      final target = TranslateLanguage.values.firstWhere(
        (language) =>
            language.bcpCode.toLowerCase() ==
            targetLanguage.toLowerCase(),
        orElse: () {
          throw Exception(
            'Idioma destino no soportado: $targetLanguage',
          );
        },
      );

      debugPrint(
        'NEXA TRANSLATION: '
        'MLKit source=${source.bcpCode} '
        'target=${target.bcpCode}',
      );

      // ============================================================
      // MODELO ORIGEN
      // ============================================================

      final sourceDownloaded =
          await _modelManager.isModelDownloaded(
        source.bcpCode,
      );

      debugPrint(
        'NEXA TRANSLATION: '
        'source model downloaded=$sourceDownloaded',
      );

      if (!sourceDownloaded) {
        debugPrint(
          'NEXA TRANSLATION: '
          'DOWNLOADING SOURCE MODEL '
          '${source.bcpCode}',
        );

        try {
          final result =
              await _modelManager.downloadModel(
            source.bcpCode,
            isWifiRequired: false,
          );

          debugPrint(
            'NEXA TRANSLATION: '
            'SOURCE MODEL DOWNLOAD RESULT=$result',
          );
        } catch (e) {
          debugPrint(
            'NEXA TRANSLATION: '
            'SOURCE MODEL DOWNLOAD ERROR=$e',
          );

          rethrow;
        }
      }

      // ============================================================
      // MODELO DESTINO
      // ============================================================

      final targetDownloaded =
          await _modelManager.isModelDownloaded(
        target.bcpCode,
      );

      debugPrint(
        'NEXA TRANSLATION: '
        'target model downloaded=$targetDownloaded',
      );

      if (!targetDownloaded) {
        debugPrint(
          'NEXA TRANSLATION: '
          'DOWNLOADING TARGET MODEL '
          '${target.bcpCode}',
        );

        try {
          final result =
              await _modelManager.downloadModel(
            target.bcpCode,
            isWifiRequired: false,
          );

          debugPrint(
            'NEXA TRANSLATION: '
            'TARGET MODEL DOWNLOAD RESULT=$result',
          );
        } catch (e) {
          debugPrint(
            'NEXA TRANSLATION: '
            'TARGET MODEL DOWNLOAD ERROR=$e',
          );

          rethrow;
        }
      }

      // ============================================================
      // CREAR TRADUCTOR
      // ============================================================

      debugPrint(
        'NEXA TRANSLATION: '
        'CREATING TRANSLATOR',
      );

      final translator = OnDeviceTranslator(
        sourceLanguage: source,
        targetLanguage: target,
      );

      try {
        debugPrint(
          'NEXA TRANSLATION: '
          'CALLING translateText()',
        );

        final translated =
            await translator.translateText(
          cleanText,
        );

        debugPrint(
          'NEXA TRANSLATION: '
          'RESULT="$translated"',
        );

        return translated;
      } finally {
        debugPrint(
          'NEXA TRANSLATION: '
          'CLOSING TRANSLATOR',
        );

        await translator.close();
      }
    } catch (e, stackTrace) {
      debugPrint(
        'NEXA TRANSLATION ERROR: $e',
      );

      debugPrint(
        'NEXA TRANSLATION STACK: $stackTrace',
      );

      rethrow;
    }
  }
}
