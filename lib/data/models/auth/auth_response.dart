class AuthResponse {
  final String token;
  final String type;
  final int id;
  final String username;
  final String email;
  final String role;

  AuthResponse({
    required this.token,
    required this.type,
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      type: json['type'],
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }

  String get bearerToken => '$type $token';
}
