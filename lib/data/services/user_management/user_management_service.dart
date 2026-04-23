import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';

class UserManagementService {
  UserManagementService({
    DioService? dioService,
    TokenManager? tokenManager,
  }) : _dioService = dioService ?? GetIt.instance<DioService>(),
       _tokenManager = tokenManager ?? GetIt.instance<TokenManager>();

  final DioService _dioService;
  final TokenManager _tokenManager;

  Future<String> _requireToken() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  Future<UserListResponse> getUsers({
    String? search,
    String? role,
    String? status,
    int page = 0,
    int size = 10,
    String sort = 'id',
    String direction = 'asc',
  }) async {
    final token = await _requireToken();

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
      '${_dioService.baseUrl}${Constants.adminUsersEndpoint}',
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
    }

    throw Exception('Failed to load users: ${response.statusCode}');
  }

  Future<List<UserResponse>> getPendingApprovals() async {
    final token = await _requireToken();

    final response = await _dioService.get(
      '${_dioService.baseUrl}${Constants.adminApprovalsEndpoint}',
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
    }

    throw Exception('Failed to load pending approvals: ${response.statusCode}');
  }

  Future<UserResponse> approveUser(int userId) async {
    final token = await _requireToken();

    final response = await _dioService.put(
      '${_dioService.baseUrl}${Constants.adminApprovalsEndpoint}/$userId/approve',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.data));
    }

    throw Exception('Failed to approve user: ${response.statusCode}');
  }

  Future<UserResponse> rejectUser(int userId) async {
    final token = await _requireToken();

    final response = await _dioService.put(
      '${_dioService.baseUrl}${Constants.adminApprovalsEndpoint}/$userId/reject',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.data));
    }

    throw Exception('Failed to reject user: ${response.statusCode}');
  }

  Future<UserResponse> changeUserStatus(int userId, bool enabled) async {
    final token = await _requireToken();

    final response = await _dioService.put(
      '${_dioService.baseUrl}${Constants.adminUsersEndpoint}/$userId/status',
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
    }

    throw Exception('Failed to change user status: ${response.statusCode}');
  }

  Future<UserResponse> changeUserRole(int userId, String role) async {
    final token = await _requireToken();

    final response = await _dioService.put(
      '${_dioService.baseUrl}${Constants.adminUsersEndpoint}/$userId/roles',
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
    }

    throw Exception('Failed to change user role: ${response.statusCode}');
  }

  Future<UserResponse> updateUser(
    int userId,
    UpdateUserRequest updateRequest,
  ) async {
    final token = await _requireToken();

    final response = await _dioService.put(
      '${_dioService.baseUrl}${Constants.adminUsersEndpoint}/$userId',
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
    }

    throw Exception('Failed to update user: ${response.statusCode}');
  }

  Future<UserResponse> createUser(CreateUserRequest createRequest) async {
    final token = await _requireToken();

    final response = await _dioService.post(
      '${_dioService.baseUrl}${Constants.adminUsersEndpoint}',
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
    }

    throw Exception('Failed to create user: ${response.statusCode}');
  }
}
