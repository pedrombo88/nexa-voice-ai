import 'package:flutter/material.dart';
import '../models/language.dart';

class LanguageSelector extends StatelessWidget {
  final String titulo;
  final Language idiomaSeleccionado;
  final ValueChanged<Language?> onChanged;

  const LanguageSelector({
    super.key,
    required this.titulo,
    required this.idiomaSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            DropdownButton<Language>(
              value: idiomaSeleccionado,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
              underline: Container(
                height: 2,
                color: Colors.blue.shade300,
              ),
              items: idiomasDisponibles.map((idioma) {
                return DropdownMenuItem(
                  value: idioma,
                  child: Text(
                    "${idioma.bandera} ${idioma.nombre}",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}