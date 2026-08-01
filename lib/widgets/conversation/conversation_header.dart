import 'package:flutter/material.dart';

import '../../models/language.dart';

class ConversationHeader extends StatelessWidget {
  final Language person1;
  final Language person2;

  const ConversationHeader({
    super.key,
    required this.person1,
    required this.person2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LanguageColumn(language: person1),

          const Icon(
            Icons.swap_horiz_rounded,
            size: 34,
          ),

          _LanguageColumn(language: person2),
        ],
      ),
    );
  }
}

class _LanguageColumn extends StatelessWidget {
  final Language language;

  const _LanguageColumn({
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          language.bandera,
          style: const TextStyle(fontSize: 34),
        ),
        const SizedBox(height: 6),
        Text(
          language.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}