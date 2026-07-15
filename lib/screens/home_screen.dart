import 'package:flutter/material.dart';
import 'language_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.language,
                color: Colors.blue,
                size: 120,
              ),

              const SizedBox(height: 30),

              const Text(
                'NEXA Voice AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Habla. Escucha. Traduce.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageScreen(),
      ),
    );
  },
                  child: const Text(
                    'COMENZAR',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}