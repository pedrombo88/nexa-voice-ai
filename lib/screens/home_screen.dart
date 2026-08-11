import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/nexa_logo.dart';

import 'call_setup_screen.dart';
import 'conversation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void intercambiarIdiomas() {
    final provider = context.read<LanguageProvider>();

    final temp = provider.person1Language;
    provider.setPerson1Language(provider.person2Language);
    provider.setPerson2Language(temp);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NEXA Voice AI'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Column(
            children: [
              const NexaLogo(),

              const SizedBox(height: 30),

              LanguageSelector(
                titulo: '👤 Persona 1',
                idiomaSeleccionado: languageProvider.person1Language,
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<LanguageProvider>()
                        .setPerson1Language(value);
                  }
                },
              ),

              const SizedBox(height: 20),

              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                child: IconButton(
                  icon: const Icon(
                    Icons.swap_vert,
                    color: Colors.blue,
                  ),
                  onPressed: intercambiarIdiomas,
                ),
              ),

              const SizedBox(height: 20),

              LanguageSelector(
                titulo: '👤 Persona 2',
                idiomaSeleccionado: languageProvider.person2Language,
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<LanguageProvider>()
                        .setPerson2Language(value);
                  }
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text(
                    'INICIAR LLAMADA TRADUCIDA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CallSetupScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.mic),
                  label: const Text(
                    'CONVERSACIÓN EN PERSONA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConversationScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}