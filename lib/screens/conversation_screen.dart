import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../managers/conversation_manager.dart';
import '../models/conversation_mode.dart';
import '../providers/language_provider.dart';

import '../widgets/conversation/conversation_header.dart';
import '../widgets/conversation/conversation_list.dart';
import '../widgets/conversation/listening_indicator.dart';
import '../widgets/conversation/speaker_panel.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late final ConversationManager _manager;

  ConversationMode? _activeSpeaker;

  @override
  void initState() {
    super.initState();

    _manager = ConversationManager();

    _initializeSpeech();

    _manager.addListener(_refresh);
  }

  Future<void> _initializeSpeech() async {
    final ready = await _manager.initialize();

    if (!ready && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo acceder al micrófono. '
            'Revisa el permiso en los Ajustes del teléfono.',
          ),
        ),
      );
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startListening(
  ConversationMode mode,
) async {
  if (_manager.isListening) {
    return;
  }

  _activeSpeaker = mode;

  final languageProvider =
      context.read<LanguageProvider>();

  final source =
      mode == ConversationMode.person1
          ? languageProvider.person1Language
          : languageProvider.person2Language;

  await _manager.startListening(
    speaker: mode,
    source: source,
  );
}

  Future<void> _releaseMicrophone() async {
    if (_activeSpeaker == null) {
      return;
    }

    final mode = _activeSpeaker!;

    _activeSpeaker = null;

    final languageProvider =
        context.read<LanguageProvider>();

    final source =
        mode == ConversationMode.person1
            ? languageProvider.person1Language
            : languageProvider.person2Language;

    final target =
        mode == ConversationMode.person1
            ? languageProvider.person2Language
            : languageProvider.person1Language;

    final speakerId =
        mode == ConversationMode.person1
            ? 'persona1'
            : 'persona2';

    await _manager.processConversation(
      source: source,
      target: target,
      speakerId: speakerId,
    );
  }

  @override
  void dispose() {
    _manager.removeListener(_refresh);
    _manager.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NEXA Voice AI'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ConversationHeader(
            person1: languageProvider.person1Language,
            person2: languageProvider.person2Language,
          ),

          ListeningIndicator(
            state: _manager.listeningState,
          ),

          Expanded(
            child: ConversationList(
              messages: _manager.history,
            ),
          ),

          SpeakerPanel(
            language: languageProvider.person1Language,
            isListening:
                _manager.isListening &&
                _manager.currentSpeaker ==
                    ConversationMode.person1,
            onMicrophonePressed: () {
              _startListening(
                ConversationMode.person1,
              );
            },
            onMicrophoneReleased:
                _releaseMicrophone,
          ),

          SpeakerPanel(
            language: languageProvider.person2Language,
            isListening:
                _manager.isListening &&
                _manager.currentSpeaker ==
                    ConversationMode.person2,
            onMicrophonePressed: () {
              _startListening(
                ConversationMode.person2,
              );
            },
            onMicrophoneReleased:
                _releaseMicrophone,
          ),
        ],
      ),
    );
  }
}