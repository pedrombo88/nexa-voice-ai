import 'package:flutter_test/flutter_test.dart';
import 'package:nexa_voice_ai/models/call_participant.dart';
import 'package:nexa_voice_ai/models/call_turn.dart';
import 'package:nexa_voice_ai/models/language.dart';
import 'package:nexa_voice_ai/services/call/local_echo_relay.dart';
import 'package:nexa_voice_ai/services/translation/hybrid_translation_service.dart';
import 'package:nexa_voice_ai/services/translation/translation_service.dart';

CallTurn _turn({String id = 't1', String sender = 'yo'}) {
  return CallTurn(
    id: id,
    senderId: sender,
    senderName: 'Prueba',
    sourceLanguage: 'es',
    targetLanguage: 'en',
    originalText: 'Hola',
    translatedText: 'Hello',
    timestamp: DateTime(2026, 1, 1),
  );
}

void main() {
  group('CallTurn', () {
    test('serializa y deserializa JSON', () {
      final turn = _turn();

      final json = turn.toJson();

      expect(json['originalText'], 'Hola');
      expect(json['translatedText'], 'Hello');

      final restored = CallTurn.fromJson(json);

      expect(restored.id, turn.id);
      expect(restored.senderId, turn.senderId);
      expect(restored.timestamp, turn.timestamp);
    });
  });

  group('LocalEchoRelay', () {
    test('crea sala y devuelve un código', () async {
      final relay = LocalEchoRelay();

      final code = await relay.createSession(
        me: const CallParticipant(id: 'yo', name: 'Ana', languageCode: 'es'),
      );

      expect(code, isNotEmpty);
      expect(relay.sessionId, code);
      expect(relay.myId, 'yo');

      relay.dispose();
    });

    test('reenvía el turno como si viniera del otro participante', () async {
      final relay = LocalEchoRelay();

      final received = <CallTurn>[];
      final sub = relay.onTurn.listen(received.add);

      await relay.createSession(
        me: const CallParticipant(id: 'yo', name: 'Ana', languageCode: 'es'),
      );

      await relay.sendTurn(_turn());

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, hasLength(1));
      expect(received.first.senderId, 'remoto');
      expect(received.first.originalText, 'Hola');

      await sub.cancel();
      relay.dispose();
    });
  });

  group('HybridTranslationService', () {
    test('usa la nube si funciona', () async {
      final hybrid = HybridTranslationService(
        cloud: _FakeTranslation('hola cloud'),
        fallback: _FakeTranslation('hola offline'),
      );

      final result = await hybrid.translate(
        text: 'hola',
        sourceLanguage: 'es',
        targetLanguage: 'en',
      );

      expect(result, 'hola cloud');
    });

    test('cae al respaldo si la nube falla', () async {
      final hybrid = HybridTranslationService(
        cloud: _FailingTranslation(),
        fallback: _FakeTranslation('hola offline'),
      );

      final result = await hybrid.translate(
        text: 'hola',
        sourceLanguage: 'es',
        targetLanguage: 'en',
      );

      expect(result, 'hola offline');
    });
  });

  group('Idiomas disponibles', () {
    test('incluye los idiomas necesarios para la llamada', () {
      final codigos = idiomasDisponibles.map((l) => l.codigo).toSet();

      expect(codigos, containsAll(['es', 'en', 'fr', 'ja', 'zh', 'ko']));
    });
  });
}

class _FakeTranslation implements TranslationService {
  final String result;

  _FakeTranslation(this.result);

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    return result;
  }
}

class _FailingTranslation implements TranslationService {
  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    throw Exception('sin internet');
  }
}