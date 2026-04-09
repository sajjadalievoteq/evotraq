import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/admin/models/admin_models.dart';

class AdminService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  AdminService({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = client,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  // Get all users with pagination and filtering
  Future<UserListResponse> getUsers({
    String? search,
    String? role,
    String? status,
    int page = 0,
    int size = 10,
    String sort = 'id',
    String direction = 'asc',
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    // Build query parameters
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sort': sort,
      'direction': direction,
    };
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (role != null && role != 'All') {
      queryParams['role'] = role;
    }
    if (status != null && status != 'All') {
      queryParams['status'] = status;
    }

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/api/admin/users').replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserListResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  // Get all pending approval requests
  Future<List<UserResponse>> getPendingApprovals() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/admin/approvals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => UserResponse.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load pending approvals: ${response.statusCode}');
    }
  }

  // Approve a user registration
  Future<UserResponse> approveUser(int userId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/api/admin/approvals/$userId/approve'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to approve user: ${response.statusCode}');
    }
  }

  // Reject a user registration
  Future<UserResponse> rejectUser(int userId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/api/admin/approvals/$userId/reject'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to reject user: ${response.statusCode}');
    }
  }

  // Change user status (activate/deactivate)
  Future<UserResponse> changeUserStatus(int userId, bool enabled) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/api/admin/users/$userId/status?enabled=$enabled'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to change user status: ${response.statusCode}');
    }
  }

  // Change user role
  Future<UserResponse> changeUserRole(int userId, String role) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/api/admin/users/$userId/roles?role=$role'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to change user role: ${response.statusCode}');
    }
  }

  // Update user details
  Future<UserResponse> updateUser(int userId, UpdateUserRequest updateRequest) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/api/admin/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateRequest.toJson()),
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  // Create a new user
  Future<UserResponse> createUser(CreateUserRequest createRequest) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/admin/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(createRequest.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.statusCode}');
    }
  }
}