import 'dart:io';

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoPath;
  final String name;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.photoPath,
    required this.name,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    final path = photoPath;

    if (path != null && File(path).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white24,
        backgroundImage: FileImage(File(path)),
      );
    }

    final initial =
        name.trim().isEmpty ? '?' : name.trim().substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade200,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.blue.shade900,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
