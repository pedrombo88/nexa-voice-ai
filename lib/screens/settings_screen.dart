import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../widgets/profile_avatar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _picker = ImagePicker();

  Future<void> _pickPhoto(SettingsProvider settings, bool isPerson1) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        return;
      }

      await settings.saveProfilePhoto(
        isPerson1: isPerson1,
        sourcePath: picked.path,
      );
    } catch (e) {
      debugPrint('NEXA SETTINGS PICK ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo elegir la foto. Inténtalo de nuevo.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Sonido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 8),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.volume_up),
              title: const Text('Sonido de traducción'),
              subtitle: const Text(
                'Lee en voz alta la traducción al soltar el micrófono. '
                'Desactívalo para silenciar la voz.',
              ),
              value: settings.speakTranslations,
              onChanged: (value) {
                settings.setSpeakTranslations(value);
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Perfiles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 8),

            _ProfileSection(
              nombre: 'Persona 1',
              name: settings.person1Name,
              photoPath: settings.person1PhotoPath,
              onNameChanged: (value) {
                settings.setPerson1Name(value);
              },
              onPickPhoto: () => _pickPhoto(settings, true),
              onRemovePhoto: () {
                settings.setPerson1PhotoPath(null);
              },
            ),

            const SizedBox(height: 20),

            _ProfileSection(
              nombre: 'Persona 2',
              name: settings.person2Name,
              photoPath: settings.person2PhotoPath,
              onNameChanged: (value) {
                settings.setPerson2Name(value);
              },
              onPickPhoto: () => _pickPhoto(settings, false),
              onRemovePhoto: () {
                settings.setPerson2PhotoPath(null);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatefulWidget {
  final String nombre;
  final String name;
  final String? photoPath;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  const _ProfileSection({
    required this.nombre,
    required this.name,
    required this.photoPath,
    required this.onNameChanged,
    required this.onPickPhoto,
    required this.onRemovePhoto,
  });

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(covariant _ProfileSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.name != widget.name &&
        _controller.text != widget.name) {
      _controller.text = widget.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ProfileAvatar(
                  photoPath: widget.photoPath,
                  name: widget.name,
                  radius: 30,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      widget.onNameChanged(value);
                    },
                    decoration: InputDecoration(
                      labelText: '${widget.nombre} · nombre',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Cambiar foto'),
                  onPressed: widget.onPickPhoto,
                ),

                const SizedBox(width: 10),

                if (widget.photoPath != null)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Quitar'),
                    onPressed: widget.onRemovePhoto,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
