class Translation {
  final String id;
  final String speakerId;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;

  const Translation({
    required this.id,
    required this.speakerId,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });

  Translation copyWith({
    String? id,
    String? speakerId,
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
  }) {
    return Translation(
      id: id ?? this.id,
      speakerId: speakerId ?? this.speakerId,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speakerId': speakerId,
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: (json['id'] as String?) ?? '',
      speakerId: (json['speakerId'] as String?) ?? '',
      originalText: (json['originalText'] as String?) ?? '',
      translatedText: (json['translatedText'] as String?) ?? '',
      sourceLanguage: (json['sourceLanguage'] as String?) ?? '',
      targetLanguage: (json['targetLanguage'] as String?) ?? '',
      timestamp:
          DateTime.tryParse((json['timestamp'] as String?) ?? '') ??
              DateTime.now(),
    );
  }
}