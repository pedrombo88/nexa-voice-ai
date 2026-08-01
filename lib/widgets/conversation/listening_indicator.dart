import 'package:flutter/material.dart';

enum ListeningState {
  idle,
  listening,
  translating,
  speaking,
}

class ListeningIndicator extends StatelessWidget {
  final ListeningState state;

  const ListeningIndicator({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String text;
    Color color;

    switch (state) {
      case ListeningState.listening:
        icon = Icons.mic;
        text = "Escuchando...";
        color = Colors.red;
        break;

      case ListeningState.translating:
        icon = Icons.translate;
        text = "Traduciendo...";
        color = Colors.orange;
        break;

      case ListeningState.speaking:
        icon = Icons.volume_up;
        text = "Reproduciendo...";
        color = Colors.green;
        break;

      case ListeningState.idle:
        icon = Icons.check_circle;
        text = "Listo";
        color = Colors.blue;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}