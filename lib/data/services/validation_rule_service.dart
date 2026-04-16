
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';

import '../../core/network/dio_service.dart';


class ValidationRuleService {
  final DioService _dioService;

  ValidationRuleService({
    required DioService dioService,
  }) : _dioService = dioService;

  Future<List<ValidationRule>> getAllRules() async {
    try {
      final response = await _dioService.get('/validation-rules');
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => ValidationRule.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting validation rules: $e');
    }
  }

  Future<ValidationRule?> getRuleById(int id) async {
    try {
      final response = await _dioService.get('/validation-rules/$id');
      return ValidationRule.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<ValidationRule>> getEnabledRules() async {
    try {
      final response = await _dioService.get('/validation-rules/enabled');
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => ValidationRule.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting enabled validation rules: $e');
    }
  }

  Future<List<ValidationRule>> getRulesByEventType(String eventType) async {
    try {
      final response = await _dioService.get('/validation-rules/event-type/$eventType');
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => ValidationRule.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting validation rules by event type: $e');
    }
  }

  Future<ValidationRule> createRule(ValidationRule rule) async {
    try {
      final response = await _dioService.post(
        '/validation-rules',
        data: rule.toJson(),
      );
      return ValidationRule.fromJson(response.data);
    } catch (e) {
      throw Exception('Error creating validation rule: $e');
    }
  }

  Future<ValidationRule?> updateRule(int id, ValidationRule rule) async {
    try {
      final response = await _dioService.put(
        '/validation-rules/$id',
        data: rule.toJson(),
      );
      return ValidationRule.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<ValidationRule?> toggleRuleStatus(int id, bool enabled) async {
    try {
      final response = await _dioService.post(
        '/validation-rules/$id/status',
        data: {'enabled': enabled},
      );
      return ValidationRule.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteRule(int id) async {
    try {
      await _dioService.delete('/validation-rules/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ValidationRule>> searchRules(String searchTerm) async {
    try {
      final response = await _dioService.get(
        '/validation-rules/search',
        queryParameters: {'q': searchTerm},
      );
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => ValidationRule.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error searching validation rules: $e');
    }
  }

  Future<void> resetToDefaults() async {
    try {
      await _dioService.post('/validation-rules/reset-defaults');
    } catch (e) {
      throw Exception('Error resetting to defaults: $e');
    }
  }

  Future<void> initializePredefinedRules() async {
    try {
      await _dioService.post('/validation-rules/initialize');
    } catch (e) {
      throw Exception('Error initializing predefined rules: $e');
    }
  }
}
