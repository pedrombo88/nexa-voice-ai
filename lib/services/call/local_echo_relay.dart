import 'dart:async';

import '../../models/call_participant.dart';
import '../../models/call_turn.dart';
import 'call_relay.dart';

/// Modo demo: simula una llamada entre dos teléfonos dentro
/// de un único dispositivo para poder probar el flujo completo.
///
/// Cada turno enviado se recibe de vuelta como si viniera del
/// otro participante.
class LocalEchoRelay implements CallRelay {
  final StreamController<CallTurn> _turnController =
      StreamController<CallTurn>.broadcast();

  final StreamController<CallParticipant?> _peerController =
      StreamController<CallParticipant?>.broadcast();

  String _sessionId = '';
  String _myId = '';

  final CallParticipant _peer = const CallParticipant(
    id: 'remoto',
    name: 'Demo (remoto)',
    languageCode: 'en',
  );

  @override
  Stream<CallTurn> get onTurn => _turnController.stream;

  @override
  Stream<CallParticipant?> get onPeer => _peerController.stream;

  @override
  String get sessionId => _sessionId;

  @override
  String get myId => _myId;

  @override
  Future<String> createSession({
    required CallParticipant me,
  }) async {
    _myId = me.id;
    _sessionId = 'demo-${DateTime.now().millisecondsSinceEpoch}';

    _peerController.add(_peer);

    return _sessionId;
  }

  @override
  Future<void> joinSession({
    required String sessionId,
    required CallParticipant me,
  }) async {
    _myId = me.id;
    _sessionId = sessionId;

    _peerController.add(_peer);
  }

  @override
  Future<void> sendTurn(CallTurn turn) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final echoed = turn.copyWith(
      id: '${turn.id}-echo',
      senderId: _peer.id,
      senderName: _peer.name,
    );

    _turnController.add(echoed);
  }

  @override
  Future<void> leave() async {}

  @override
  void dispose() {
    _turnController.close();
    _peerController.close();
  }
}
