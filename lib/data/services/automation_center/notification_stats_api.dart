import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';

typedef NotificationAuthHeaders = Future<Map<String, String>> Function();

class NotificationStatsApi {
  NotificationStatsApi({
    required DioService dioService,
    required NotificationAuthHeaders authHeaders,
  }) : _dioService = dioService,
       _authHeaders = authHeaders;

  final DioService _dioService;
  final NotificationAuthHeaders _authHeaders;

  Future<NotificationStats> getSubscriptionStats(String id) async {
    try {
      final response = await _dioService.get(
        '${_dioService.baseUrl}/notifications/subscriptions/$id/stats',
        headers: await _authHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      if (response.statusCode == 200) {
        return NotificationStats.fromJson(json.decode(response.data));
      }
      throw ApiException(
        message: 'Failed to fetch subscription stats',
        statusCode: response.statusCode,
      );
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch subscription stats: $error');
    }
  }

  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final response = await _dioService.get(
        '${_dioService.baseUrl}/notifications/stats',
        headers: await _authHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      if (response.statusCode == 200) {
        return json.decode(response.data);
      }
      throw ApiException(
        message: 'Failed to fetch system stats',
        statusCode: response.statusCode,
      );
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch system stats: $error');
    }
  }
}
