import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import '../../domain/models/notification_subscription.dart' as domain;

class NotificationApiService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  NotificationApiService({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = client,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Subscription Management
  Future<List<domain.NotificationSubscription>> getSubscriptions({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Backend returns a direct list, not a paginated response
        if (responseData is List) {
          return responseData
              .map((json) => domain.NotificationSubscription.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw ApiException(
          message: 'Failed to fetch subscriptions',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch subscriptions: $e');
    }
  }

  Future<domain.NotificationSubscription> createSubscription(
      domain.CreateSubscriptionRequest request) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return domain.NotificationSubscription.fromJson(json.decode(response.body));
      } else {
        throw ApiException(
          message: 'Failed to create subscription',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to create subscription: $e');
    }
  }

  Future<domain.NotificationSubscription> getSubscription(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return domain.NotificationSubscription.fromJson(json.decode(response.body));
      } else {
        throw ApiException(
          message: 'Failed to fetch subscription',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch subscription: $e');
    }
  }

  Future<domain.NotificationSubscription> updateSubscription(
    String id,
    domain.CreateSubscriptionRequest request,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.put(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions/$id'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return domain.NotificationSubscription.fromJson(json.decode(response.body));
      } else {
        throw ApiException(
          message: 'Failed to update subscription',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to update subscription: $e');
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.delete(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          message: 'Failed to delete subscription',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to delete subscription: $e');
    }
  }

  Future<void> pauseSubscription(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions/$id/pause'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          message: 'Failed to pause subscription',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to pause subscription: $e');
    }
  }

  Future<void> resumeSubscription(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions/$id/resume'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          message: 'Failed to resume subscription',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to resume subscription: $e');
    }
  }

  // Webhook Management
  Future<List<domain.WebhookNotification>> getWebhookHistory(
    String subscriptionId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions/$subscriptionId/webhooks?limit=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Backend returns a direct list, not a paginated response
        if (responseData is List) {
          return responseData
              .map((json) => domain.WebhookNotification.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw ApiException(
          message: 'Failed to fetch webhook history',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch webhook history: $e');
    }
  }

  Future<Map<String, dynamic>> testWebhook(String webhookUrl) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/webhooks/test'),
        headers: headers,
        body: json.encode({'webhookUrl': webhookUrl}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          message: 'Failed to test webhook',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to test webhook: $e');
    }
  }

  Future<Map<String, dynamic>> testEmail(String emailAddress) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/emails/test'),
        headers: headers,
        body: jsonEncode({
          'emailAddress': emailAddress,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          message: 'Failed to test email: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to test email: $e');
    }
  }

  Future<void> retryWebhook(String notificationId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/webhooks/$notificationId/retry'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          message: 'Failed to retry webhook',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to retry webhook: $e');
    }
  }

  // Batch Management - TODO: Create NotificationBatch domain model
  /*
  Future<List<domain.NotificationBatch>> getBatchHistory(
    String subscriptionId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions/$subscriptionId/batches?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['content'] != null) {
          return (responseData['content'] as List)
              .map((json) => domain.NotificationBatch.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw ApiException(
          message: 'Failed to fetch batch history',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch batch history: $e');
    }
  }
  */

  // Statistics
  Future<domain.NotificationStats> getSubscriptionStats(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/subscriptions/$id/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return domain.NotificationStats.fromJson(json.decode(response.body));
      } else {
        throw ApiException(
          message: 'Failed to fetch subscription stats',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch subscription stats: $e');
    }
  }

  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/notifications/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          message: 'Failed to fetch system stats',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch system stats: $e');
    }
  }
}
