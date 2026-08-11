/// Un turno de voz dentro de una llamada traducida.
///
/// El remitente graba su frase, la traduce a la lengua del
/// destinatario y publica ambos textos a través del relay.
class CallTurn {
  final String id;

  /// Identifica al remitente dentro de la sala (creador/visitante).
  final String senderId;
  final String senderName;
  final String sourceLanguage;
  final String targetLanguage;
  final String originalText;
  final String translatedText;
  final DateTime timestamp;

  const CallTurn({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.originalText,
    required this.translatedText,
    required this.timestamp,
  });

  CallTurn copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? sourceLanguage,
    String? targetLanguage,
    String? originalText,
    String? translatedText,
    DateTime? timestamp,
  }) {
    return CallTurn(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'originalText': originalText,
      'translatedText': translatedText,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CallTurn.fromJson(Map<String, dynamic> json) {
    return CallTurn(
      id: (json['id'] as String?) ?? '',
      senderId: (json['senderId'] as String?) ?? '',
      senderName: (json['senderName'] as String?) ?? '',
      sourceLanguage: (json['sourceLanguage'] as String?) ?? '',
      targetLanguage: (json['targetLanguage'] as String?) ?? '',
      originalText: (json['originalText'] as String?) ?? '',
      translatedText: (json['translatedText'] as String?) ?? '',
      timestamp:
          DateTime.tryParse((json['timestamp'] as String?) ?? '') ??
              DateTime.now(),
    );
  }
}