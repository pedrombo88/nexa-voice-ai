import 'package:flutter/material.dart';

class ConversationBubble extends StatelessWidget {
  final String speaker;
  final String originalText;
  final String translatedText;
  final bool isMe;

  const ConversationBubble({
    super.key,
    required this.speaker,
    required this.originalText,
    required this.translatedText,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor =
        isMe ? Colors.blue.shade600 : Colors.grey.shade800;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              speaker,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              originalText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            const Divider(
              color: Colors.white24,
              height: 25,
            ),

            Text(
              translatedText,
              style: const TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}