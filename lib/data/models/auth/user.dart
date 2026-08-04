class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool enabled;
  final bool hasProfilePicture;

  final bool darkMode;
  final String language;
  final bool emailNotifications;
  final bool appNotifications;

  /// Client preference: GLN used for pharma return flows. Server-persisted.
  final String? operationalGln;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.enabled,
    this.hasProfilePicture = false,
    this.darkMode = false,
    this.language = 'English',
    this.emailNotifications = true,
    this.appNotifications = true,
    this.operationalGln,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? 'USER',
      enabled: json['enabled'] ?? true,
      hasProfilePicture: json['hasProfilePicture'] ?? false,
      darkMode: json['darkMode'] ?? false,
      language: json['language'] ?? 'English',
      emailNotifications: json['emailNotifications'] ?? true,
      appNotifications: json['appNotifications'] ?? true,
      operationalGln: _readOptionalGln(json['operationalGln']),
    );
  }

  static String? _readOptionalGln(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    bool? enabled,
    bool? hasProfilePicture,
    bool? darkMode,
    String? language,
    bool? emailNotifications,
    bool? appNotifications,
    String? operationalGln,
    bool clearOperationalGln = false,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      enabled: enabled ?? this.enabled,
      hasProfilePicture: hasProfilePicture ?? this.hasProfilePicture,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      appNotifications: appNotifications ?? this.appNotifications,
      operationalGln: clearOperationalGln
          ? null
          : (operationalGln ?? this.operationalGln),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'enabled': enabled,
    'hasProfilePicture': hasProfilePicture,
    'darkMode': darkMode,
    'language': language,
    'emailNotifications': emailNotifications,
    'appNotifications': appNotifications,
    'operationalGln': operationalGln,
  };
}
