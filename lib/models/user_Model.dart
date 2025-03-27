class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;
  final List<String> identificationHistory;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
    this.identificationHistory = const [],
    this.preferences = const {},
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      photoUrl: json['photoUrl'],
      identificationHistory: List<String>.from(json['identificationHistory'] ?? []),
      preferences: json['preferences'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'identificationHistory': identificationHistory,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    List<String>? identificationHistory,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      identificationHistory: identificationHistory ?? this.identificationHistory,
      preferences: preferences ?? this.preferences,
    );
  }
}

