import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _kSpeakTranslations = 'speakTranslations';
  static const String _kPerson1Name = 'person1Name';
  static const String _kPerson2Name = 'person2Name';
  static const String _kPerson1Photo = 'person1Photo';
  static const String _kPerson2Photo = 'person2Photo';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  bool _speakTranslations = true;
  String _person1Name = 'Persona 1';
  String _person2Name = 'Persona 2';
  String? _person1PhotoPath;
  String? _person2PhotoPath;

  bool get speakTranslations => _speakTranslations;
  String get person1Name => _person1Name;
  String get person2Name => _person2Name;
  String? get person1PhotoPath => _person1PhotoPath;
  String? get person2PhotoPath => _person2PhotoPath;

  Future<void> load() async {
    _speakTranslations =
        await _prefs.getBool(_kSpeakTranslations) ?? true;
    _person1Name =
        await _prefs.getString(_kPerson1Name) ?? 'Persona 1';
    _person2Name =
        await _prefs.getString(_kPerson2Name) ?? 'Persona 2';
    _person1PhotoPath = await _prefs.getString(_kPerson1Photo);
    _person2PhotoPath = await _prefs.getString(_kPerson2Photo);

    notifyListeners();
  }

  Future<void> setSpeakTranslations(bool value) async {
    _speakTranslations = value;
    notifyListeners();

    await _prefs.setBool(_kSpeakTranslations, value);
  }

  Future<void> setPerson1Name(String value) async {
    _person1Name = _normalizeName(value, 'Persona 1');
    notifyListeners();

    await _prefs.setString(_kPerson1Name, _person1Name);
  }

  Future<void> setPerson2Name(String value) async {
    _person2Name = _normalizeName(value, 'Persona 2');
    notifyListeners();

    await _prefs.setString(_kPerson2Name, _person2Name);
  }

  Future<void> setPerson1PhotoPath(String? path) async {
    _person1PhotoPath = path;
    notifyListeners();

    if (path == null) {
      await _prefs.remove(_kPerson1Photo);
    } else {
      await _prefs.setString(_kPerson1Photo, path);
    }
  }

  Future<void> setPerson2PhotoPath(String? path) async {
    _person2PhotoPath = path;
    notifyListeners();

    if (path == null) {
      await _prefs.remove(_kPerson2Photo);
    } else {
      await _prefs.setString(_kPerson2Photo, path);
    }
  }

  /// Copia la foto elegida a la carpeta de documentos de la app y
  /// guarda la ruta para que persista entre reinicios.
  Future<void> saveProfilePhoto({
    required bool isPerson1,
    required String sourcePath,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final target =
          '${dir.path}/foto_persona_${isPerson1 ? '1' : '2'}.jpg';

      final sourceFile = File(sourcePath);

      if (!sourceFile.existsSync()) {
        return;
      }

      final targetFile = File(target);

      if (targetFile.existsSync()) {
        await targetFile.delete();
      }

      await sourceFile.copy(target);

      if (isPerson1) {
        await setPerson1PhotoPath(target);
      } else {
        await setPerson2PhotoPath(target);
      }
    } catch (e) {
      debugPrint('NEXA SETTINGS PHOTO ERROR: $e');
    }
  }

  String _normalizeName(String value, String fallback) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return fallback;
    }

    return trimmed;
  }
}
