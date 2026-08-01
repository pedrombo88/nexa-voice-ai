import 'package:flutter/material.dart';

import '../../models/translation.dart';
import '../conversation_bubble.dart';

class ConversationList extends StatelessWidget {
  final List<Translation> messages;

  const ConversationList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          "Pulsa un micrófono para comenzar la conversación",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];

        return ConversationBubble(
          speaker: message.speakerId,
          originalText: message.originalText,
          translatedText: message.translatedText,
          isMe: message.speakerId == "persona1",
        );
      },
    );
  }
}