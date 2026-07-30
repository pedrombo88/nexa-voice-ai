import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final SpeechToText speech = SpeechToText();

  bool escuchando = false;
  String textoReconocido = "Pulsa el micrófono para empezar";

  Future<void> escuchar() async {
    if (!escuchando) {
      bool disponible = await speech.initialize();

      if (disponible) {
        setState(() {
          escuchando = true;
        });

        speech.listen(
          onResult: (resultado) {
            setState(() {
              textoReconocido = resultado.recognizedWords;
            });
          },
        );
      }
    } else {
      await speech.stop();

      setState(() {
        escuchando = false;
      });
    }
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversación"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Expanded(
              child: Center(
                child: Text(
                  textoReconocido,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            FloatingActionButton(
              onPressed: escuchar,
              child: Icon(
                escuchando ? Icons.stop : Icons.mic,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
