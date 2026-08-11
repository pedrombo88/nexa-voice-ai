/// Información de un participante en la sala de llamada.
class CallParticipant {
  final String id;
  final String name;
  final String languageCode;

  const CallParticipant({
    required this.id,
    required this.name,
    required this.languageCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'languageCode': languageCode,
    };
  }

  factory CallParticipant.fromJson(Map<String, dynamic> json) {
    return CallParticipant(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      languageCode: (json['languageCode'] as String?) ?? '',
    );
  }
}