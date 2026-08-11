import '../../models/call_participant.dart';
import '../../models/call_turn.dart';

/// Capa de comunicación de una llamada traducida entre dos dispositivos.
///
/// Implementaciones:
///  - [LocalEchoRelay]: modo demo, ambos participantes en el mismo teléfono.
///  - [FirebaseCallRelay]: llamadas reales entre dos teléfonos mediante
///    Firebase Realtime Database.
abstract class CallRelay {
  /// Turnos de voz recibidos del otro participante.
  Stream<CallTurn> get onTurn;

  /// Información del otro participante (null si aún no está conectado).
  Stream<CallParticipant?> get onPeer;

  /// Identificador de la sala actual.
  String get sessionId;

  /// Identificador local dentro de la sala.
  String get myId;

  /// Crea una sala nueva y devuelve el código para compartir.
  Future<String> createSession({
    required CallParticipant me,
  });

  /// Se une a una sala existente.
  Future<void> joinSession({
    required String sessionId,
    required CallParticipant me,
  });

  /// Publica un turno de voz hacia el otro participante.
  Future<void> sendTurn(CallTurn turn);

  /// Cierra la sesión.
  Future<void> leave();

  /// Libera recursos.
  void dispose();
}
