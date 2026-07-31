import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversation_mode.dart';
import '../models/translation.dart';
import '../providers/language_provider.dart';
import '../providers/translation_provider.dart';
import '../services/speech/speech_service.dart';
import '../services/tts/tts_service.dart';
import '../widgets/conversation_bubble.dart';
import '../widgets/microphone_button.dart';

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

  final List<Translation> _messages = [];

  Future<void> _toggleListening(ConversationMode mode) async {
    if (_isListening) {
      await _speechService.stopListening();

      if (!mounted) return;

      setState(() {
        _isListening = false;
        _currentMode = null;
      });

      return;
    }

    if (!mounted) return;

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
    });

    await _speechService.startListening(
      localeId: source.speechLocale,
      onResult: (text) async {
        if (text.isEmpty) return;

        final translated = await _translator.translate(
          text: text,
          sourceLanguage: source.codigo,
          targetLanguage: target.codigo,
        );

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
        });
      },
    );
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
        title: Text(
          "${languageProvider.person1Language.bandera} ${languageProvider.person1Language.nombre} ↔ ${languageProvider.person2Language.bandera} ${languageProvider.person2Language.nombre}",
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          Text(
            "${languageProvider.person1Language.bandera} ${languageProvider.person1Language.nombre}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          MicrophoneButton(
            isListening:
                _isListening && _currentMode == ConversationMode.person1,
            onPressed: () => _toggleListening(ConversationMode.person1),
          ),

          const Divider(height: 40),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                return ConversationBubble(
                  speaker: message.speakerId,
                  originalText: message.originalText,
                  translatedText: message.translatedText,
                  isMe: message.speakerId == "persona1",
                );
              },
            ),
          ),

          const Divider(height: 40),

          Text(
            "${languageProvider.person2Language.bandera} ${languageProvider.person2Language.nombre}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: MicrophoneButton(
              isListening:
                  _isListening && _currentMode == ConversationMode.person2,
              onPressed: () => _toggleListening(ConversationMode.person2),
            ),
          ),
        ],
      ),
    );
  }
}