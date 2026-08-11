/// Configuración central de la aplicación.
///
/// Edita estos valores para activar la traducción en la nube y/o el
/// backend de llamadas entre dispositivos.
class AppConfig {
  // ============================================================
  // TRADUCCIÓN EN LA NUBE (Google Cloud Translation)
  // ============================================================
  //
  // API key de Google Cloud Translation v2.
  // Cómo obtenerla:
  //   1. Ve a https://console.cloud.google.com/
  //   2. Crea un proyecto y activa "Cloud Translation API".
  //   3. Crea una API key en "APIs y servicios" -> "Credenciales".
  //
  // Si se deja VACÍA, la app usa un endpoint de demostración sin
  // costo (no oficial) para pruebas. Si falla, cae en la traducción
  // on-device (Google ML Kit) que funciona sin internet.
  static const String cloudTranslationApiKey = '';

  // ============================================================
  // BACKEND DE LLAMADAS (Firebase Realtime Database)
  // ============================================================
  //
  // Para conectar DOS teléfonos en una llamada, activa Firebase:
  //   1. Crea un proyecto en https://console.firebase.google.com/
  //   2. Añade una app de Android (en "Configuración del proyecto"
  //      -> "Tus apps" verás los datos de FirebaseOptions).
  //   3. Activa "Realtime Database" en modo de prueba.
  //
  // Si el relay está DESACTIVADO, la app funciona en "modo demo":
  // los dos participantes se prueban dentro del mismo dispositivo.
  static const bool firebaseRelayEnabled = false;

  static const String firebaseApiKey = '';
  static const String firebaseAppId = '';
  static const String firebaseMessagingSenderId = '';
  static const String firebaseProjectId = '';
  static const String firebaseDatabaseURL = '';
  static const String firebaseStorageBucket = '';
}