import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/language.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import 'call_screen.dart';

class CallSetupScreen extends StatefulWidget {
  const CallSetupScreen({super.key});

  @override
  State<CallSetupScreen> createState() => _CallSetupScreenState();
}

class _CallSetupScreenState extends State<CallSetupScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _codeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    final configuredName =
        context.read<SettingsProvider>().person1Name;

    _nameController.text =
        configuredName == 'Persona 1' ? 'Yo' : configuredName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCall(Language myLanguage, Language peerLanguage) {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe tu nombre')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          isCreator: true,
          myName: name,
          myLanguage: myLanguage,
          peerLanguage: peerLanguage,
        ),
      ),
    );
  }

  void _joinCall(Language myLanguage, Language peerLanguage) {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe tu nombre')),
      );
      return;
    }

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el código de la sala')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          isCreator: false,
          sessionId: code,
          myName: name,
          myLanguage: myLanguage,
          peerLanguage: peerLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Llamada traducida'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Llamada con traducción en tiempo real',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Cada persona habla en su idioma. '
                'Tu teléfono traduce y el otro participante '
                'escucha tu voz traducida.',
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<Language>(
                initialValue: languageProvider.person1Language,
                decoration: const InputDecoration(
                  labelText: 'Mi idioma',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                items: idiomasDisponibles.map((language) {
                  return DropdownMenuItem<Language>(
                    value: language,
                    child: Text(
                      '${language.bandera} ${language.nombre}',
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

              const SizedBox(height: 16),

              DropdownButtonFormField<Language>(
                initialValue: languageProvider.person2Language,
                decoration: const InputDecoration(
                  labelText: 'Idioma de la otra persona',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.groups),
                ),
                items: idiomasDisponibles.map((language) {
                  return DropdownMenuItem<Language>(
                    value: language,
                    child: Text(
                      '${language.bandera} ${language.nombre}',
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

              const SizedBox(height: 28),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text(
                    'CREAR LLAMADA',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _startCall(
                    languageProvider.person1Language,
                    languageProvider.person2Language,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Divider(),

              const SizedBox(height: 8),

              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Código de la sala',
                  hintText: 'Ej: -O34bR9TzQ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.call_received),
                  label: const Text(
                    'UNIRSE A LLAMADA',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _joinCall(
                    languageProvider.person1Language,
                    languageProvider.person2Language,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Card(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Modo demo: sin backend, ambos lados se prueban '
                          'en este mismo dispositivo. Consulta lib/config/'
                          'app_config.dart para activar Firebase.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
