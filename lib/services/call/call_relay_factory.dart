import '../../config/app_config.dart';
import 'call_relay.dart';
import 'firebase_call_relay.dart';
import 'local_echo_relay.dart';

class CallRelayFactory {
  /// Devuelve el relay configurado: Firebase (dos teléfonos) o
  /// modo demo local (un solo dispositivo).
  ///
  /// En modo demo, [peerLanguageCode] define el idioma del participante
  /// remoto simulado.
  static CallRelay create({String peerLanguageCode = 'en'}) {
    if (AppConfig.firebaseRelayEnabled) {
      return FirebaseCallRelay();
    }

    return LocalEchoRelay(peerLanguageCode: peerLanguageCode);
  }
}
