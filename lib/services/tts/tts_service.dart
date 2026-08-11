import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Servicio de voz con resolución de idioma instalado.
///
/// Si el idioma solicitado no está disponible en el dispositivo,
/// busca una voz del mismo idioma (p. ej: pedir "en-US" y usar una
/// voz "en-GB") para evitar que el motor lea el texto con fonética
/// de otro idioma o lo deletree letra por letra.
class TtsService {
  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;
  List<String> _availableLanguages = const [];
  List<Map<String, String>> _availableVoices = const [];

  Future<void> initialize() async {
    if (_initialized) return;

    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);

    // En Android priorizamos el motor de Google, que suele tener
    // más voces instaladas por idioma.
    try {
      await _tts.setEngine('com.google.android.tts');
    } catch (e) {
      // Otros motores (iOS, etc.) no usan setEngine.
    }

    _availableLanguages = await _fetchLanguages();
    _availableVoices = await _fetchVoices();

    _initialized = true;
  }

  Future<void> speak({
    required String text,
    required String language,
  }) async {
    await initialize();

    final resolved = _resolveLanguage(language);

    var languageOk = false;

    try {
      languageOk = await _setLanguage(resolved);
    } catch (e) {
      debugPrint('NEXA TTS: setLanguage("$resolved") error: $e');
    }

    // Si el idioma resuelto no funcionó, intenta la voz explícita.
    if (!languageOk) {
      final applied = await _applyVoiceForLanguage(language);

      debugPrint(
        'NEXA TTS: idioma "$language" no aplicado, '
        'voz explicita=${applied ? "si" : "no"}',
      );
    }

    await _tts.speak(text);
  }

  // ============================================================
  // RESOLUCIÓN DE IDIOMA
  // ============================================================

  /// Devuelve el locale instalado más parecido al solicitado.
  ///
  /// 1. Coincidencia exacta (en-US == en-US).
  /// 2. Coincidencia por prefijo (en-US -> en-GB).
  /// 3. Si no hay nada, el solicitado (el motor decidirá).
  String _resolveLanguage(String requested) {
    if (_availableLanguages.isEmpty) {
      return requested;
    }

    final requestedKey = _normalize(requested);

    final exact = _availableLanguages
        .where((l) => _normalize(l) == requestedKey)
        .toList();

    if (exact.isNotEmpty) {
      return exact.first;
    }

    final prefix = requestedKey.split('_').first;

    final byPrefix = _availableLanguages
        .where((l) => _normalize(l).startsWith('${prefix}_'))
        .toList();

    if (byPrefix.isNotEmpty) {
      return byPrefix.first;
    }

    final exactSimple = _availableLanguages
        .where((l) => _normalize(l) == prefix)
        .toList();

    if (exactSimple.isNotEmpty) {
      return exactSimple.first;
    }

    return requested;
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_');
  }

  Future<bool> _setLanguage(String language) async {
    final result = await _tts.setLanguage(language);

    // En Android setLanguage devuelve 1 si OK; en iOS suele
    // lanzar excepción si el idioma no existe.
    return result == 1 || result == '1' || result == null;
  }

  // ============================================================
  // VOCES DISPONIBLES
  // ============================================================

  /// Busca una voz instalada del idioma solicitado y la aplica.
  /// Devuelve true si encontró y aplicó una voz.
  Future<bool> _applyVoiceForLanguage(String language) async {
    final prefix = _normalize(language).split('_').first;

    final voice = _availableVoices
        .where((v) => v['locale'] != null)
        .where(
          (v) =>
              _normalize(v['locale']!)
                  .startsWith(prefix),
        )
        .toList();

    if (voice.isEmpty) {
      return false;
    }

    try {
      await _tts.setVoice(voice.first);
      return true;
    } catch (e) {
      debugPrint('NEXA TTS: setVoice error: $e');
      return false;
    }
  }

  Future<List<String>> _fetchLanguages() async {
    try {
      final raw = await _tts.getLanguages;

      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('NEXA TTS: getLanguages error: $e');
    }

    return const [];
  }

  Future<List<Map<String, String>>> _fetchVoices() async {
    try {
      final raw = await _tts.getVoices;

      if (raw is List) {
        return raw.map((e) {
          final map = e as Map;
          return map.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('NEXA TTS: getVoices error: $e');
    }

    return const [];
  }

  // ============================================================
  // DETENER
  // ============================================================

  Future<void> stop() async {
    await _tts.stop();
  }
}