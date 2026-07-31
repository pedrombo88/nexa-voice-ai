import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/language.dart';
import '../providers/language_provider.dart';
import 'conversation_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar idiomas"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Idioma de la Persona 1",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<Language>(
              initialValue: provider.person1Language,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: idiomasDisponibles.map((language) {
                return DropdownMenuItem<Language>(
                  value: language,
                  child: Text(
                    "${language.bandera} ${language.nombre}",
                  ),
                );
              }).toList(),
              onChanged: (language) {
                if (language != null) {
                  context
                      .read<LanguageProvider>()
                      .setPerson1Language(language);
                }
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Idioma de la Persona 2",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<Language>(
              initialValue: provider.person2Language,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: idiomasDisponibles.map((language) {
                return DropdownMenuItem<Language>(
                  value: language,
                  child: Text(
                    "${language.bandera} ${language.nombre}",
                  ),
                );
              }).toList(),
              onChanged: (language) {
                if (language != null) {
                  context
                      .read<LanguageProvider>()
                      .setPerson2Language(language);
                }
              },
            ),

            const Spacer(),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConversationScreen(),
                    ),
                  );
                },
                child: const Text(
                  "INICIAR CONVERSACIÓN",
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}