import '../../config/app_config.dart';
import 'call_relay.dart';
import 'firebase_call_relay.dart';
import 'local_echo_relay.dart';

class CallRelayFactory {
  /// Devuelve el relay configurado: Firebase (dos teléfonos) o
  /// modo demo local (un solo dispositivo).
  static CallRelay create() {
    if (AppConfig.firebaseRelayEnabled) {
      return FirebaseCallRelay();
    }

    return LocalEchoRelay();
  }
}
