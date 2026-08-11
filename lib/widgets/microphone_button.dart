import 'package:flutter/material.dart';

class MicrophoneButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final VoidCallback? onReleased;

  const MicrophoneButton({
    super.key,
    required this.isListening,
    required this.onPressed,
    this.onReleased,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,

      onPointerDown: (_) {
        onPressed();
      },

      onPointerUp: (_) {
        onReleased?.call();
      },

      onPointerCancel: (_) {
        onReleased?.call();
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isListening
              ? Colors.red
              : Colors.blue,
          boxShadow: [
            BoxShadow(
              blurRadius: isListening ? 20 : 8,
              spreadRadius: isListening ? 5 : 1,
              color: (isListening
                      ? Colors.red
                      : Colors.blue)
                  .withValues(alpha: 0.35),
            ),
          ],
        ),
        child: Icon(
          isListening
              ? Icons.mic
              : Icons.mic_none,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }
}