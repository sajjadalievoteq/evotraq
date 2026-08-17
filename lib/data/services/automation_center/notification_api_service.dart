import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/page_response_utils.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart'
    as domain;

class NotificationApiService {
  final DioService _dioService;

  NotificationApiService({required DioService dioService})
    : _dioService = dioService;

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<domain.NotificationSubscription>> getSubscriptions({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dioService.get(
        '${_dioService.baseUrl}/notifications/subscriptions',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.data);
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
    domain.CreateSubscriptionRequest request,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dioService.post(
        '${_dioService.baseUrl}/notifications/subscriptions',
        headers: headers,
        data: json.encode(request.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return domain.NotificationSubscription.fromJson(
          json.decode(response.data),
        );
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
      final response = await _dioService.get(
        '${_dioService.baseUrl}/notifications/subscriptions/$id',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return domain.NotificationSubscription.fromJson(
          json.decode(response.data),
        );
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
      final response = await _dioService.put(
        '${_dioService.baseUrl}/notifications/subscriptions/$id',
        headers: headers,
        data: json.encode(request.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return domain.NotificationSubscription.fromJson(
          json.decode(response.data),
        );
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
      final response = await _dioService.delete(
        '${_dioService.baseUrl}/notifications/subscriptions/$id',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
      final response = await _dioService.post(
        '${_dioService.baseUrl}/notifications/subscriptions/$id/pause',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
      final response = await _dioService.post(
        '${_dioService.baseUrl}/notifications/subscriptions/$id/resume',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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

  /// Paginated webhook history for one subscription.
  Future<({List<domain.WebhookNotification> items, bool hasMore, int page})>
      getWebhookHistory(
    String subscriptionId, {
    int page = 0,
    int size = 20,
    String? outcome,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final clamped = PageResponseUtils.clampSize(size);
      final query = StringBuffer(
        '${_dioService.baseUrl}/notifications/subscriptions/$subscriptionId/webhooks'
        '?page=$page&size=$clamped',
      );
      if (outcome != null && outcome.isNotEmpty && outcome != 'all') {
        query.write('&outcome=${Uri.encodeQueryComponent(outcome)}');
      }
      final response = await _dioService.get(
        query.toString(),
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.data);
        final raw = PageResponseUtils.normalizeBody(decoded, fallbackSize: clamped);
        final history = <domain.WebhookNotification>[];
        for (final item in PageResponseUtils.contentList(raw)) {
          if (item is! Map) continue;
          try {
            history.add(
              domain.WebhookNotification.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          } catch (_) {
            // Skip malformed rows rather than failing the whole panel.
          }
        }
        return (
          items: history,
          hasMore: !PageResponseUtils.isLast(raw),
          page: PageResponseUtils.pageNumber(raw),
        );
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

  /// Cross-subscription Activity feed (newest first).
  Future<({List<domain.WebhookNotification> items, bool hasMore, int page})>
      getDeliveryActivity({
    int page = 0,
    int size = 20,
    String? outcome,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final clamped = PageResponseUtils.clampSize(size);
      final query = StringBuffer(
        '${_dioService.baseUrl}/notifications/activity?page=$page&size=$clamped',
      );
      if (outcome != null && outcome.isNotEmpty && outcome != 'all') {
        query.write('&outcome=${Uri.encodeQueryComponent(outcome)}');
      }
      final response = await _dioService.get(
        query.toString(),
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.data);
        final raw = PageResponseUtils.normalizeBody(decoded, fallbackSize: clamped);
        final history = <domain.WebhookNotification>[];
        for (final item in PageResponseUtils.contentList(raw)) {
          if (item is! Map) continue;
          try {
            history.add(
              domain.WebhookNotification.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          } catch (_) {
            // Skip malformed rows rather than failing the whole panel.
          }
        }
        return (
          items: history,
          hasMore: !PageResponseUtils.isLast(raw),
          page: PageResponseUtils.pageNumber(raw),
        );
      } else {
        throw ApiException(
          message: 'Failed to fetch delivery activity',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch delivery activity: $e');
    }
  }

  Future<Map<String, dynamic>> testWebhook(String webhookUrl) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dioService.post(
        '${_dioService.baseUrl}/notifications/webhooks/test',
        headers: headers,
        data: json.encode({'webhookUrl': webhookUrl}),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.data);
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
      final response = await _dioService.post(
        '${_dioService.baseUrl}/notifications/emails/test',
        headers: headers,
        data: jsonEncode({'emailAddress': emailAddress}),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
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
      final response = await _dioService.post(
        '${_dioService.baseUrl}/notifications/webhooks/$notificationId/retry',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 202 &&
          response.statusCode != 204) {
        throw ApiExceptionMapper.fromHttpResponse(
          response,
          fallbackMessage: "Couldn't retry this delivery. Please try again.",
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: "Couldn't retry this delivery. Please try again.",
      );
    }
  }

  /// Loads batch history for a subscription (last [limit] rows).
  Future<List<domain.NotificationBatch>> getBatchHistory(
    String subscriptionId, {
    int limit = 50,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dioService.get(
        '${_dioService.baseUrl}/notifications/subscriptions/$subscriptionId/batches?limit=$limit',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.data);
        if (responseData is List) {
          final history = <domain.NotificationBatch>[];
          for (final item in responseData) {
            if (item is! Map) continue;
            try {
              history.add(
                domain.NotificationBatch.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              );
            } catch (_) {
              // Skip malformed rows rather than failing the whole panel.
            }
          }
          return history;
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

  /// Triggers a manual retry for an exhausted batch.
  Future<void> retryBatch(String batchId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dioService.post(
        '${_dioService.baseUrl}/notifications/batches/$batchId/retry',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 202 &&
          response.statusCode != 204) {
        throw ApiExceptionMapper.fromHttpResponse(
          response,
          fallbackMessage: "Couldn't retry this batch. Please try again.",
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: "Couldn't retry this batch. Please try again.",
      );
    }
  }

  Future<domain.NotificationStats> getSubscriptionStats(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dioService.get(
        '${_dioService.baseUrl}/notifications/subscriptions/$id/stats',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return domain.NotificationStats.fromJson(json.decode(response.data));
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
      final response = await _dioService.get(
        '${_dioService.baseUrl}/notifications/stats',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.data);
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
