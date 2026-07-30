import 'dart:async';

import 'translation_service.dart';

class FakeTranslationService implements TranslationService {
  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    // Simula el tiempo que tardaría una API real
    await Future.delayed(const Duration(milliseconds: 500));

    return "[$targetLanguage] $text";
  }
}