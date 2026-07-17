class Language {
  final String nombre;
  final String bandera;
  final String codigo;

  const Language({
    required this.nombre,
    required this.bandera,
    required this.codigo,
  });
}

const List<Language> idiomasDisponibles = [
  Language(
    nombre: 'Español',
    bandera: '🇪🇸',
    codigo: 'es',
  ),
  Language(
    nombre: 'Inglés',
    bandera: '🇬🇧',
    codigo: 'en',
  ),
  Language(
    nombre: 'Francés',
    bandera: '🇫🇷',
    codigo: 'fr',
  ),
  Language(
    nombre: 'Alemán',
    bandera: '🇩🇪',
    codigo: 'de',
  ),
  Language(
    nombre: 'Italiano',
    bandera: '🇮🇹',
    codigo: 'it',
  ),
  Language(
    nombre: 'Portugués',
    bandera: '🇵🇹',
    codigo: 'pt',
  ),
];