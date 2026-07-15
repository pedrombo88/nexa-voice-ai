import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar idiomas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Idioma de la Persona 1',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: 'Español',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Español',
                  child: Text('🇪🇸 Español'),
                ),
                DropdownMenuItem(
                  value: 'Inglés',
                  child: Text('🇬🇧 Inglés'),
                ),
                DropdownMenuItem(
                  value: 'Francés',
                  child: Text('🇫🇷 Francés'),
                ),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: 30),

            const Text(
              'Idioma de la Persona 2',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: 'Inglés',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Español',
                  child: Text('🇪🇸 Español'),
                ),
                DropdownMenuItem(
                  value: 'Inglés',
                  child: Text('🇬🇧 Inglés'),
                ),
                DropdownMenuItem(
                  value: 'Francés',
                  child: Text('🇫🇷 Francés'),
                ),
              ],
              onChanged: (value) {},
            ),

            const Spacer(),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('INICIAR CONVERSACIÓN'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}