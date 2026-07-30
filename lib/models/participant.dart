class Participant {
  final String id;
  final String name;
  final String languageCode;
  final String languageName;
  final bool isLocalUser;

  const Participant({
    required this.id,
    required this.name,
    required this.languageCode,
    required this.languageName,
    required this.isLocalUser,
  });

  Participant copyWith({
    String? id,
    String? name,
    String? languageCode,
    String? languageName,
    bool? isLocalUser,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      languageCode: languageCode ?? this.languageCode,
      languageName: languageName ?? this.languageName,
      isLocalUser: isLocalUser ?? this.isLocalUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'languageCode': languageCode,
      'languageName': languageName,
      'isLocalUser': isLocalUser,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      name: json['name'],
      languageCode: json['languageCode'],
      languageName: json['languageName'],
      isLocalUser: json['isLocalUser'],
    );
  }
}