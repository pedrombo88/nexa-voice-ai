import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import 'translation_service.dart';

/// Traducción en la nube mediante Google Cloud Translation.
///
/// - Si hay API key configurada, usa el endpoint oficial v2.
/// - Si no, usa un endpoint de demostración gratuito (no oficial)
///   para poder probar la calidad en la nube sin configuración.
class CloudTranslationService implements TranslationService {
  final String _apiKey;

  CloudTranslationService({String? apiKey})
      : _apiKey = apiKey ?? AppConfig.cloudTranslationApiKey;

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
      'NEXA CLOUD: '
      'source=$sourceLanguage '
      'target=$targetLanguage '
      'text="$cleanText"',
    );

    try {
      if (_apiKey.isNotEmpty) {
        return await _translateWithApiKey(
          cleanText,
          sourceLanguage,
          targetLanguage,
        );
      }

      return await _translateWithDemoEndpoint(
        cleanText,
        sourceLanguage,
        targetLanguage,
      );
    } catch (e) {
      debugPrint('NEXA CLOUD ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // ENDPOINT OFICIAL v2 (requiere API key)
  // ============================================================

  Future<String> _translateWithApiKey(
    String text,
    String source,
    String target,
  ) async {
    final uri = Uri.https(
      'translation.googleapis.com',
      '/language/translate/v2',
      {'key': _apiKey},
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': [text],
        'source': source,
        'target': target,
        'format': 'text',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Cloud API HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    final translated = (body['data']['translations'] as List)
        .first['translatedText'] as String;

    debugPrint('NEXA CLOUD RESULT: "$translated"');

    return translated;
  }

  // ============================================================
  // ENDPOINT DE DEMOSTRACIÓN (sin API key)
  // ============================================================

  Future<String> _translateWithDemoEndpoint(
    String text,
    String source,
    String target,
  ) async {
    final uri = Uri.https(
      'translate.googleapis.com',
      '/translate_a/single',
      {
        'client': 'gtx',
        'sl': source,
        'tl': target,
        'dt': 't',
        'q': text,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Demo API HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    // Estructura: [[["traducido", ...], ...], ...]
    final buffer = StringBuffer();

    for (final segment in body[0] as List) {
      buffer.write((segment as List)[0] as String);
    }

    final translated = buffer.toString();

    debugPrint('NEXA CLOUD RESULT: "$translated"');

    return translated;
  }
}
