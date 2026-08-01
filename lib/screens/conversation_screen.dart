import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../models/conversation_mode.dart';
import '../models/translation.dart';
import '../providers/language_provider.dart';
import '../providers/translation_provider.dart';
import '../services/speech/speech_service.dart';
import '../services/tts/tts_service.dart';
import '../widgets/conversation/conversation_header.dart';
import '../widgets/conversation/conversation_list.dart';
import '../widgets/conversation/listening_indicator.dart';
import '../widgets/conversation/speaker_panel.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  

  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();
  final _translator = TranslationProvider.getTranslator();

  bool _isListening = false;
  ConversationMode? _currentMode;

  ListeningState _state = ListeningState.idle;

  final List<Translation> _messages = [];

  Future<void> _toggleListening(ConversationMode mode) async {
    if (_isListening) {
      await _speechService.stopListening();

      if (!mounted) return;

      setState(() {
        _isListening = false;
        _currentMode = null;
        _state = ListeningState.idle;
      });

      return;
    }

    final languageProvider = context.read<LanguageProvider>();

    final source = mode == ConversationMode.person1
        ? languageProvider.person1Language
        : languageProvider.person2Language;

    final target = mode == ConversationMode.person1
        ? languageProvider.person2Language
        : languageProvider.person1Language;

    final initialized = await _speechService.initialize();

    if (!initialized) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo iniciar el reconocimiento de voz."),
        ),
      );

      return;
    }

    setState(() {
      _isListening = true;
      _currentMode = mode;
      _state = ListeningState.listening;
    });

    final text = await _speechService.listen(
      localeId: source.speechLocale,
    );

    if (!mounted) return;

    if (text == null || text.isEmpty) {
      setState(() {
        _isListening = false;
        _currentMode = null;
        _state = ListeningState.idle;
      });
      return;
    }

    setState(() {
      _state = ListeningState.translating;
    });

    final translated = await _translator.translate(
      text: text,
      sourceLanguage: source.codigo,
      targetLanguage: target.codigo,
    );

    if (!mounted) return;

    setState(() {
      _state = ListeningState.speaking;
    });

    await _ttsService.speak(
      text: translated,
      language: target.ttsLocale,
    );

    if (!mounted) return;

    setState(() {
      _messages.add(
        Translation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          speakerId:
              mode == ConversationMode.person1 ? "persona1" : "persona2",
          originalText: text,
          translatedText: translated,
          sourceLanguage: source.codigo,
          targetLanguage: target.codigo,
          timestamp: DateTime.now(),
        ),
      );

      _isListening = false;
      _currentMode = null;
      _state = ListeningState.idle;
    });
  }

  @override
  void dispose() {
    _speechService.stopListening();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("NEXA Voice AI"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ConversationHeader(
            person1: languageProvider.person1Language,
            person2: languageProvider.person2Language,
          ),

          ListeningIndicator(
            state: _state,
          ),

          SpeakerPanel(
            language: languageProvider.person1Language,
            isListening:
                _isListening && _currentMode == ConversationMode.person1,
            onMicrophonePressed: () =>
                _toggleListening(ConversationMode.person1),
          ),

          Expanded(
            child: ConversationList(
              messages: _messages,
            ),
          ),

          SpeakerPanel(
            language: languageProvider.person2Language,
            isListening:
                _isListening && _currentMode == ConversationMode.person2,
            onMicrophonePressed: () =>
                _toggleListening(ConversationMode.person2),
          ),
        ],
      ),
    );
  }
}