import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';

/// Service for validation rule API operations
/// Part of Phase 3: Event Validation Service - Business Rule Validation
abstract class ValidationRuleService {
  Future<List<ValidationRule>> getAllRules();
  Future<ValidationRule?> getRuleById(int id);
  Future<List<ValidationRule>> getEnabledRules();
  Future<List<ValidationRule>> getRulesByEventType(String eventType);
  Future<ValidationRule> createRule(ValidationRule rule);
  Future<ValidationRule?> updateRule(int id, ValidationRule rule);
  Future<ValidationRule?> toggleRuleStatus(int id, bool enabled);
  Future<bool> deleteRule(int id);
  Future<List<ValidationRule>> searchRules(String searchTerm);
  Future<void> resetToDefaults();
  Future<void> initializePredefinedRules();
}

/// Implementation of ValidationRuleService
class ValidationRuleServiceImpl implements ValidationRuleService {
  final http.Client httpClient;
  final TokenManager tokenManager;
  final AppConfig appConfig;

  ValidationRuleServiceImpl({
    required this.httpClient,
    required this.tokenManager,
    required this.appConfig,
  });

  String get _baseUrl => '${appConfig.apiBaseUrl}/validation-rules';

  Future<Map<String, String>> get _headers async {
    final token = await tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ValidationRule>> getAllRules() async {
    try {
      final response = await httpClient.get(
        Uri.parse(_baseUrl),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ValidationRule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get validation rules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting validation rules: $e');
    }
  }

  @override
  Future<ValidationRule?> getRuleById(int id) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return ValidationRule.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get validation rule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting validation rule: $e');
    }
  }

  @override
  Future<List<ValidationRule>> getEnabledRules() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$_baseUrl/enabled'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ValidationRule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get enabled validation rules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting enabled validation rules: $e');
    }
  }

  @override
  Future<List<ValidationRule>> getRulesByEventType(String eventType) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$_baseUrl/event-type/$eventType'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ValidationRule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get validation rules by event type: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting validation rules by event type: $e');
    }
  }

  @override
  Future<ValidationRule> createRule(ValidationRule rule) async {
    try {
      final response = await httpClient.post(
        Uri.parse(_baseUrl),
        headers: await _headers,
        body: json.encode(rule.toJson()),
      );

      if (response.statusCode == 201) {
        return ValidationRule.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create validation rule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating validation rule: $e');
    }
  }

  @override
  Future<ValidationRule?> updateRule(int id, ValidationRule rule) async {
    try {
      final response = await httpClient.put(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers,
        body: json.encode(rule.toJson()),
      );

      if (response.statusCode == 200) {
        return ValidationRule.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to update validation rule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating validation rule: $e');
    }
  }

  @override
  Future<ValidationRule?> toggleRuleStatus(int id, bool enabled) async {
    try {
      final response = await httpClient.patch(
        Uri.parse('$_baseUrl/$id/status'),
        headers: await _headers,
        body: json.encode({'enabled': enabled}),
      );

      if (response.statusCode == 200) {
        return ValidationRule.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to toggle rule status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling rule status: $e');
    }
  }

  @override
  Future<bool> deleteRule(int id) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Failed to delete validation rule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting validation rule: $e');
    }
  }

  @override
  Future<List<ValidationRule>> searchRules(String searchTerm) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(searchTerm)}'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ValidationRule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search validation rules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching validation rules: $e');
    }
  }

  @override
  Future<void> resetToDefaults() async {
    try {
      final response = await httpClient.post(
        Uri.parse('$_baseUrl/reset-defaults'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reset to defaults: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error resetting to defaults: $e');
    }
  }

  @override
  Future<void> initializePredefinedRules() async {
    try {
      final response = await httpClient.post(
        Uri.parse('$_baseUrl/initialize'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to initialize predefined rules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error initializing predefined rules: $e');
    }
  }
}
