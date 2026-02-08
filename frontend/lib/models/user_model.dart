class UserModel {
  final String id;
  final String username;
  final String email;
  final String nativeLanguage;
  final String targetLanguage;
  final String proficiencyLevel;
  final String? displayName;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.proficiencyLevel,
    this.displayName,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      nativeLanguage: json['native_language'],
      targetLanguage: json['target_language'],
      proficiencyLevel: json['proficiency_level'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'native_language': nativeLanguage,
      'target_language': targetLanguage,
      'proficiency_level': proficiencyLevel,
      'display_name': displayName,
      'avatar_url': avatarUrl,
    };
  }
}
