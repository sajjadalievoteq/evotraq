import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/admin/models/admin_models.dart';

class AdminService {
  final DioService _dioService;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  AdminService({
    required DioService dioService,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _dioService = dioService,
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

    final response = await _dioService.get(
      '${_appConfig.apiBaseUrl}/api/admin/users',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return UserListResponse.fromJson(json.decode(response.data));
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

    final response = await _dioService.get(
      '${_appConfig.apiBaseUrl}/api/admin/approvals',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => UserResponse.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load pending approvals: ${response.statusCode}',
      );
    }
  }

  // Approve a user registration
  Future<UserResponse> approveUser(int userId) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _dioService.put(
      '${_appConfig.apiBaseUrl}/api/admin/approvals/$userId/approve',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.data));
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

    final response = await _dioService.put(
      '${_appConfig.apiBaseUrl}/api/admin/approvals/$userId/reject',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.data));
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

    final response = await _dioService.put(
      '${_appConfig.apiBaseUrl}/api/admin/users/$userId/status',
      queryParameters: {'enabled': enabled},
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.data));
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

    final response = await _dioService.put(
      '${_appConfig.apiBaseUrl}/api/admin/users/$userId/roles',
      queryParameters: {'role': role},
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to change user role: ${response.statusCode}');
    }
  }

  // Update user details
  Future<UserResponse> updateUser(
    int userId,
    UpdateUserRequest updateRequest,
  ) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _dioService.put(
      '${_appConfig.apiBaseUrl}/api/admin/users/$userId',
      data: jsonEncode(updateRequest.toJson()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.data));
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

    final response = await _dioService.post(
      '${_appConfig.apiBaseUrl}/api/admin/users',
      data: jsonEncode(createRequest.toJson()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserResponse.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to create user: ${response.statusCode}');
    }
  }
}
