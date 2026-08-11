import 'package:flutter/material.dart';

import '../../models/language.dart';
import '../microphone_button.dart';
import '../profile_avatar.dart';
import 'wave_animation.dart';

class SpeakerPanel extends StatelessWidget {
  final Language language;
  final String name;
  final String? photoPath;
  final bool isListening;
  final VoidCallback onMicrophonePressed;
  final VoidCallback? onMicrophoneReleased;

  const SpeakerPanel({
    super.key,
    required this.language,
    required this.name,
    this.photoPath,
    required this.isListening,
    required this.onMicrophonePressed,
    this.onMicrophoneReleased,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileAvatar(
                  photoPath: photoPath,
                  name: name,
                  radius: 20,
                ),

                const SizedBox(width: 10),

                Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '${language.bandera} ${language.nombre}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            WaveAnimation(
              isListening: isListening,
              child: MicrophoneButton(
                isListening: isListening,
                onPressed: onMicrophonePressed,
                onReleased: onMicrophoneReleased,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
