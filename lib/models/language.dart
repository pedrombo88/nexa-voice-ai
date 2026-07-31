class Language {
  final String nombre;
  final String bandera;

  /// Código ISO
  final String codigo;

  /// Locale para Speech To Text
  final String speechLocale;

  /// Locale para Text To Speech
  final String ttsLocale;

  const Language({
    required this.nombre,
    required this.bandera,
    required this.codigo,
    required this.speechLocale,
    required this.ttsLocale,
  });
}

const List<Language> idiomasDisponibles = [
  Language(
    nombre: 'Español',
    bandera: '🇪🇸',
    codigo: 'es',
    speechLocale: 'es_ES',
    ttsLocale: 'es-ES',
  ),
  Language(
    nombre: 'Inglés',
    bandera: '🇺🇸',
    codigo: 'en',
    speechLocale: 'en_US',
    ttsLocale: 'en-US',
  ),
  Language(
    nombre: 'Francés',
    bandera: '🇫🇷',
    codigo: 'fr',
    speechLocale: 'fr_FR',
    ttsLocale: 'fr-FR',
  ),
  Language(
    nombre: 'Alemán',
    bandera: '🇩🇪',
    codigo: 'de',
    speechLocale: 'de_DE',
    ttsLocale: 'de-DE',
  ),
  Language(
    nombre: 'Italiano',
    bandera: '🇮🇹',
    codigo: 'it',
    speechLocale: 'it_IT',
    ttsLocale: 'it-IT',
  ),
  Language(
    nombre: 'Portugués',
    bandera: '🇵🇹',
    codigo: 'pt',
    speechLocale: 'pt_PT',
    ttsLocale: 'pt-PT',
  ),
];