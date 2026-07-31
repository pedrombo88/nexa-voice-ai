import 'package:flutter/material.dart';

import '../models/language.dart';

class LanguageProvider extends ChangeNotifier {
  Language _person1Language = idiomasDisponibles.first;
  Language _person2Language = idiomasDisponibles[1];

  Language get person1Language => _person1Language;
  Language get person2Language => _person2Language;

  void setPerson1Language(Language language) {
    _person1Language = language;
    notifyListeners();
  }

  void setPerson2Language(Language language) {
    _person2Language = language;
    notifyListeners();
  }
}