import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import '../../models/call_participant.dart';
import '../../models/call_turn.dart';
import 'call_relay.dart';

/// Llamadas reales entre dos teléfonos usando Firebase Realtime Database.
///
/// Estructura en la base de datos:
///   nexa_calls/sessions/`sessionId`/
///     creator: `{id, name, languageCode}`
///     joiner:  `{id, name, languageCode}`
///     turns/`turnId`: `{ ...CallTurn }`
class FirebaseCallRelay implements CallRelay {
  static bool _initialized = false;

  final StreamController<CallTurn> _turnController =
      StreamController<CallTurn>.broadcast();

  final StreamController<CallParticipant?> _peerController =
      StreamController<CallParticipant?>.broadcast();

  String _sessionId = '';
  String _myId = '';

  DatabaseReference? _sessionRef;
  final List<StreamSubscription<DatabaseEvent>> _subscriptions = [];

  @override
  Stream<CallTurn> get onTurn => _turnController.stream;

  @override
  Stream<CallParticipant?> get onPeer => _peerController.stream;

  @override
  String get sessionId => _sessionId;

  @override
  String get myId => _myId;

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  static Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    if (AppConfig.firebaseProjectId.isEmpty ||
        AppConfig.firebaseApiKey.isEmpty ||
        AppConfig.firebaseAppId.isEmpty ||
        AppConfig.firebaseDatabaseURL.isEmpty) {
      throw StateError(
        'Firebase no configurado: rellena los valores de '
        'lib/config/app_config.dart para activar el relay.',
      );
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: AppConfig.firebaseApiKey,
          appId: AppConfig.firebaseAppId,
          messagingSenderId: AppConfig.firebaseMessagingSenderId,
          projectId: AppConfig.firebaseProjectId,
          databaseURL: AppConfig.firebaseDatabaseURL,
          storageBucket: AppConfig.firebaseStorageBucket,
        ),
      );
    }

    _initialized = true;
  }

  Future<DatabaseReference> _sessionsRef() async {
    await _ensureInitialized();
    return FirebaseDatabase.instance.ref().child('nexa_calls/sessions');
  }

  // ============================================================
  // CREAR SALA
  // ============================================================

  @override
  Future<String> createSession({
    required CallParticipant me,
  }) async {
    _myId = me.id;

    final sessions = await _sessionsRef();

    final newRef = sessions.push();
    _sessionId = newRef.key!;
    _sessionRef = newRef;

    await newRef.update({
      'creator': me.toJson(),
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'turns': {},
    });

    _listenPeer();
    _listenTurns();

    return _sessionId;
  }

  // ============================================================
  // UNIRSE A SALA
  // ============================================================

  @override
  Future<void> joinSession({
    required String sessionId,
    required CallParticipant me,
  }) async {
    _myId = me.id;
    _sessionId = sessionId;

    final sessions = await _sessionsRef();
    _sessionRef = sessions.child(sessionId);

    final snapshot = await _sessionRef!.child('creator').get();

    if (!snapshot.exists) {
      throw Exception('La sala $sessionId no existe o ya terminó.');
    }

    final creator = CallParticipant.fromJson(
      Map<String, dynamic>.from(snapshot.value as Map),
    );

    await _sessionRef!.child('joiner').set(me.toJson());

    _peerController.add(creator);

    _listenPeer();
    _listenTurns();
  }

  // ============================================================
  // ESCUCHAS
  // ============================================================

  void _listenPeer() {
    final sub = _sessionRef!
        .child('joiner')
        .onValue
        .listen((event) {
          final value = event.snapshot.value;

          if (value is Map) {
            _peerController.add(
              CallParticipant.fromJson(
                Map<String, dynamic>.from(value),
              ),
            );
          }
        });

    _subscriptions.add(sub);
  }

  void _listenTurns() {
    final sub = _sessionRef!
        .child('turns')
        .onChildAdded
        .listen((event) {
          final value = event.snapshot.value;

          if (value is! Map) {
            return;
          }

          final turn = CallTurn.fromJson(
            Map<String, dynamic>.from(value),
          );

          if (turn.senderId != _myId) {
            _turnController.add(turn);
          }
        });

    _subscriptions.add(sub);
  }

  // ============================================================
  // ENVIAR TURNO
  // ============================================================

  @override
  Future<void> sendTurn(CallTurn turn) async {
    await _sessionRef!.child('turns').child(turn.id).set(turn.toJson());
  }

  // ============================================================
  // CERRAR
  // ============================================================

  @override
  Future<void> leave() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();

    if (_sessionRef != null) {
      try {
        await _sessionRef!.child('joiner').remove();
      } catch (e) {
        debugPrint('NEXA RELAY LEAVE: $e');
      }
    }
  }

  @override
  void dispose() {
    unawaited(_disposeAsync());
  }

  Future<void> _disposeAsync() async {
    await leave();
    await _turnController.close();
    await _peerController.close();
  }
}
