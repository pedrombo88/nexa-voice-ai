import 'package:flutter/material.dart';
import '../models/language.dart';
import '../widgets/language_selector.dart';
import '../widgets/nexa_logo.dart';

import 'conversation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Language idiomaPersona1 = idiomasDisponibles[0];
  Language idiomaPersona2 = idiomasDisponibles[1];

  void intercambiarIdiomas() {
    setState(() {
      final temp = idiomaPersona1;
      idiomaPersona1 = idiomaPersona2;
      idiomaPersona2 = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEXA Voice AI'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const NexaLogo(),

              const SizedBox(height: 35),

              LanguageSelector(
                titulo: '👤 Persona 1',
                idiomaSeleccionado: idiomaPersona1,
                onChanged: (value) {
                  setState(() {
                    idiomaPersona1 = value!;
                  });
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
                idiomaSeleccionado: idiomaPersona2,
                onChanged: (value) {
                  setState(() {
                    idiomaPersona2 = value!;
                  });
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text(
                    'INICIAR CONVERSACIÓN',
                    style: TextStyle(
                      fontSize: 18,
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