import 'package:flutter/material.dart';

class NexaLogo extends StatelessWidget {
  const NexaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(
          Icons.translate,
          size: 70,
          color: Colors.blue,
        ),
        SizedBox(height: 10),
        Text(
          'NEXA Voice AI',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Traducción de voz en tiempo real',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}