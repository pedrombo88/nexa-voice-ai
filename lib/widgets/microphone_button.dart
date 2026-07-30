import 'package:flutter/material.dart';

class MicrophoneButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const MicrophoneButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: FloatingActionButton(
        elevation: 8,
        backgroundColor:
            isListening ? Colors.red : Theme.of(context).primaryColor,
        onPressed: onPressed,
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}