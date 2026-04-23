class UserResponse {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool enabled;
  final bool emailVerified;
  final String approvalStatus;
  final String createdAt;
  final String updatedAt;

  UserResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.enabled,
    required this.emailVerified,
    required this.approvalStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      enabled: json['enabled'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      approvalStatus: json['approvalStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class UserListResponse {
  final List<UserResponse> users;
  final int currentPage;
  final int totalItems;
  final int totalPages;

  UserListResponse({
    required this.users,
    required this.currentPage,
    required this.totalItems,
    required this.totalPages,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> usersJson = json['users'] ?? [];
    final List<UserResponse> users =
        usersJson.map((user) => UserResponse.fromJson(user)).toList();

    return UserListResponse(
      users: users,
      currentPage: json['currentPage'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class CreateUserRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final bool enabled;

  CreateUserRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.enabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'enabled': enabled,
    };
  }
}

class UpdateUserRequest {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;

  UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;

    return data;
  }
}
