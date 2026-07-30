class Conversation {
  final String id;
  final DateTime createdAt;
  final String languagePerson1;
  final String languagePerson2;
  final List<String> originalMessages;
  final List<String> translatedMessages;

  const Conversation({
    required this.id,
    required this.createdAt,
    required this.languagePerson1,
    required this.languagePerson2,
    required this.originalMessages,
    required this.translatedMessages,
  });

  Conversation copyWith({
    String? id,
    DateTime? createdAt,
    String? languagePerson1,
    String? languagePerson2,
    List<String>? originalMessages,
    List<String>? translatedMessages,
  }) {
    return Conversation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      languagePerson1: languagePerson1 ?? this.languagePerson1,
      languagePerson2: languagePerson2 ?? this.languagePerson2,
      originalMessages: originalMessages ?? this.originalMessages,
      translatedMessages:
          translatedMessages ?? this.translatedMessages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'languagePerson1': languagePerson1,
      'languagePerson2': languagePerson2,
      'originalMessages': originalMessages,
      'translatedMessages': translatedMessages,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      languagePerson1: json['languagePerson1'],
      languagePerson2: json['languagePerson2'],
      originalMessages:
          List<String>.from(json['originalMessages']),
      translatedMessages:
          List<String>.from(json['translatedMessages']),
    );
  }
}