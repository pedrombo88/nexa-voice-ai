import 'package:flutter/material.dart';

import '../models/translation.dart';
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

  final List<Translation> _messages = [
    Translation(
      id: "1",
      speakerId: "persona1",
      originalText: "Hola, ¿cómo estás?",
      translatedText: "Hello, how are you?",
      sourceLanguage: "es",
      targetLanguage: "en",
      timestamp: DateTime.now(),
    ),
    Translation(
      id: "2",
      speakerId: "persona2",
      originalText: "I'm fine, thank you.",
      translatedText: "Estoy bien, gracias.",
      sourceLanguage: "en",
      targetLanguage: "es",
      timestamp: DateTime.now(),
    ),
  ];

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();

      setState(() {
        _isListening = false;
      });

      return;
    }

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
    });

    await _speechService.startListening(
      localeId: "es_ES",
      onResult: (text) async {
        if (text.isEmpty) return;

        final translated = await _translator.translate(
          text: text,
          sourceLanguage: "es",
          targetLanguage: "en",
        );

        // 🔊 Reproducir la traducción
        await _ttsService.speak(
          text: translated,
          language: "en-US",
        );

        if (!mounted) return;

        setState(() {
          _messages.add(
            Translation(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              speakerId: "persona1",
              originalText: text,
              translatedText: translated,
              sourceLanguage: "es",
              targetLanguage: "en",
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("NEXA Voice AI"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: MicrophoneButton(
              isListening: _isListening,
              onPressed: _toggleListening,
            ),
          ),
        ],
      ),
    );
  }
}