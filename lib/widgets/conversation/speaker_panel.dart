import 'package:flutter/material.dart';

import '../../models/language.dart';
import '../microphone_button.dart';

class SpeakerPanel extends StatelessWidget {
  final Language language;
  final bool isListening;
  final VoidCallback onMicrophonePressed;

  const SpeakerPanel({
    super.key,
    required this.language,
    required this.isListening,
    required this.onMicrophonePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "${language.bandera} ${language.nombre}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            MicrophoneButton(
              isListening: isListening,
              onPressed: onMicrophonePressed,
            ),
          ],
        ),
      ),
    );
  }
}