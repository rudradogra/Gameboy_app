class User {
  final String id;
  final String email;
  final String username;
  final String name;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.createdAt,
    this.lastLogin,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class DatingProfile {
  final String id;
  final String userId;
  final int age;
  final String bio;
  final List<String> interests;
  final String location;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User? user;

  DatingProfile({
    required this.id,
    required this.userId,
    required this.age,
    required this.bio,
    required this.interests,
    required this.location,
    required this.imageUrls,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory DatingProfile.fromJson(Map<String, dynamic> json) {
    return DatingProfile(
      id: json['id'],
      userId: json['user_id'],
      age: json['age'],
      bio: json['bio'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      location: json['location'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: json['users'] != null ? User.fromJson(json['users']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'age': age,
      'bio': bio,
      'interests': interests,
      'location': location,
      'image_urls': imageUrls,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Match {
  final String id;
  final User otherUser;
  final DatingProfile? otherUserProfile;
  final String currentUserAction;
  final String? otherUserAction;
  final bool isMutual;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Match({
    required this.id,
    required this.otherUser,
    this.otherUserProfile,
    required this.currentUserAction,
    this.otherUserAction,
    required this.isMutual,
    required this.createdAt,
    this.updatedAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      otherUser: User.fromJson(json['other_user']),
      otherUserProfile: json['other_user']['profile'] != null
          ? DatingProfile.fromJson(json['other_user']['profile'])
          : null,
      currentUserAction: json['current_user_action'],
      otherUserAction: json['other_user_action'],
      isMutual: json['is_mutual'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

class AuthResponse {
  final bool success;
  final User? user;
  final String? token;
  final String? error;
  final String? message;

  AuthResponse({
    required this.success,
    this.user,
    this.token,
    this.error,
    this.message,
  });

  factory AuthResponse.fromApiResponse(Map<String, dynamic> response) {
    return AuthResponse(
      success: response['success'] ?? false,
      user:
          response['success'] &&
              response['data'] != null &&
              response['data']['user'] != null
          ? User.fromJson(response['data']['user'])
          : null,
      token: response['success'] && response['data'] != null
          ? response['data']['token']
          : null,
      error: response['error'],
      message: response['message'],
    );
  }
}
