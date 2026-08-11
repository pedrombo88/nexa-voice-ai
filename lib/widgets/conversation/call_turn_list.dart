import 'package:flutter/material.dart';

import '../../models/call_turn.dart';
import '../conversation_bubble.dart';

class CallTurnList extends StatefulWidget {
  final List<CallTurn> turns;
  final String myId;

  const CallTurnList({
    super.key,
    required this.turns,
    required this.myId,
  });

  @override
  State<CallTurnList> createState() => _CallTurnListState();
}

class _CallTurnListState extends State<CallTurnList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant CallTurnList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.turns.length != oldWidget.turns.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.turns.isEmpty) {
      return const Center(
        child: Text(
          'Mantén pulsado el micrófono para hablar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.turns.length,
      itemBuilder: (context, index) {
        final turn = widget.turns[index];

        return ConversationBubble(
          speaker: turn.senderName,
          originalText: turn.originalText,
          translatedText: turn.translatedText,
          isMe: turn.senderId == widget.myId,
        );
      },
    );
  }
}