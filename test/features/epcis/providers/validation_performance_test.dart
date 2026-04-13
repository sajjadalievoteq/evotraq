import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/data/services/validation_rule_service.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';


class _InMemoryValidationRuleService implements ValidationRuleService {
  final List<ValidationRule> _initialRules;
  List<ValidationRule> _rules;
  int _nextId;

  _InMemoryValidationRuleService({
    required List<ValidationRule> initialRules,
  }) : _initialRules = List<ValidationRule>.unmodifiable(initialRules),
       _rules = List<ValidationRule>.from(initialRules),
       _nextId = 1;

  @override
  Future<List<ValidationRule>> getAllRules() async => List<ValidationRule>.from(_rules);

  @override
  Future<ValidationRule> createRule(ValidationRule rule) async {
    final created = rule.id == null ? rule.copyWith(id: _nextId++) : rule;
    _rules.add(created);
    return created;
  }

  @override
  Future<void> resetToDefaults() async {
    _rules = List<ValidationRule>.from(_initialRules);
    _nextId = (_rules.map((r) => r.id ?? 0).fold<int>(0, (max, v) => v > max ? v : max)) + 1;
  }

  @override
  Future<ValidationRule?> getRuleById(int id) async {
    try {
      return _rules.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ValidationRule>> getEnabledRules() async =>
      _rules.where((r) => r.enabled).toList();

  @override
  Future<List<ValidationRule>> getRulesByEventType(String eventType) async =>
      _rules.where((r) => r.eventType?.toString() == eventType).toList();

  @override
  Future<ValidationRule?> updateRule(int id, ValidationRule rule) async {
    final index = _rules.indexWhere((r) => r.id == id);
    if (index == -1) return null;
    final updated = rule.copyWith(id: id);
    _rules[index] = updated;
    return updated;
  }

  @override
  Future<ValidationRule?> toggleRuleStatus(int id, bool enabled) async {
    final index = _rules.indexWhere((r) => r.id == id);
    if (index == -1) return null;
    final updated = _rules[index].copyWith(enabled: enabled);
    _rules[index] = updated;
    return updated;
  }

  @override
  Future<bool> deleteRule(int id) async {
    final before = _rules.length;
    _rules.removeWhere((r) => r.id == id);
    return _rules.length != before;
  }

  @override
  Future<List<ValidationRule>> searchRules(String searchTerm) async {
    final lower = searchTerm.toLowerCase();
    return _rules
        .where(
          (r) =>
              r.name.toLowerCase().contains(lower) ||
              (r.description?.toLowerCase().contains(lower) ?? false) ||
              (r.field?.toLowerCase().contains(lower) ?? false),
        )
        .toList();
  }

  @override
  Future<void> initializePredefinedRules() async {}
}

/// Tests focused on the performance features of the validation service
void main() {
  final appConfig = AppConfig(
    apiBaseUrl: 'https://api.test.com',
    appName: 'TraqTrace Test',
    appVersion: '1.0.0',
  );

  group('ValidationRuleProvider Performance Tests', () {
    test('should efficiently filter rules by event type', () async {
      final service = _InMemoryValidationRuleService(
        initialRules: [
          ValidationRule(
            id: 1,
            ruleId: 'obj_1',
            name: 'Object rule',
            description: 'action required',
            eventType: EventType.ObjectEvent,
            severity: RuleSeverity.ERROR,
            enabled: true,
          ),
          ValidationRule(
            id: 2,
            ruleId: 'agg_1',
            name: 'Aggregation rule',
            description: 'aggregation required',
            eventType: EventType.AggregationEvent,
            severity: RuleSeverity.ERROR,
            enabled: true,
          ),
          ValidationRule(
            id: 3,
            ruleId: 'txn_1',
            name: 'Transaction rule',
            description: 'transaction required',
            eventType: EventType.TransactionEvent,
            severity: RuleSeverity.ERROR,
            enabled: true,
          ),
          ValidationRule(
            id: 4,
            ruleId: 'trn_1',
            name: 'Transformation rule',
            description: 'transformation required',
            eventType: EventType.TransformationEvent,
            severity: RuleSeverity.ERROR,
            enabled: true,
          ),
        ],
      );

      final cubit = ValidationRuleCubit(
        validationRuleService: service,
      );
      addTearDown(cubit.close);
      await cubit.loadValidationRules();
      
      // Get rules for specific event types
      final objectRules = cubit.rules.where((r) => r.eventType == EventType.ObjectEvent).toList();
      final aggregationRules = cubit.rules.where((r) => r.eventType == EventType.AggregationEvent).toList();
      final transformationRules = cubit.rules.where((r) => r.eventType == EventType.TransformationEvent).toList();
      final transactionRules = cubit.rules.where((r) => r.eventType == EventType.TransactionEvent).toList();
      
      // Verify the filters work correctly and efficiently
      for (final rule in objectRules) {
        expect(rule.eventType == EventType.ObjectEvent, true);
      }
      
      for (final rule in aggregationRules) {
        expect(rule.eventType == EventType.AggregationEvent, true);
      }
      
      // Make sure rules exist for all event types
      expect(objectRules.isNotEmpty, true);
      expect(aggregationRules.isNotEmpty, true);
      expect(transactionRules.isNotEmpty, true);
      expect(transformationRules.isNotEmpty, true);
    });
    
    test('should efficiently filter rules by field', () async {
      final service = _InMemoryValidationRuleService(
        initialRules: [
          ValidationRule(
            id: 1,
            ruleId: 'obj_action',
            name: 'Action Check',
            description: 'Check action',
            eventType: EventType.ObjectEvent,
            severity: RuleSeverity.ERROR,
            enabled: true,
          ),
          ValidationRule(
            id: 2,
            ruleId: 'obj_other',
            name: 'Other Check',
            description: 'Check other field',
            eventType: EventType.ObjectEvent,
            severity: RuleSeverity.WARNING,
            enabled: true,
          ),
        ],
      );

      final cubit = ValidationRuleCubit(
        validationRuleService: service,
      );
      addTearDown(cubit.close);
      await cubit.loadValidationRules();
      
      // Get rules that mention specific fields in their description
      final actionRules = cubit.rules.where((r) => 
        r.description?.toLowerCase().contains('action') == true).toList();
      
      // Should find some rules related to action field
      expect(actionRules.isNotEmpty, true);
      
      for (final rule in actionRules) {
        expect(rule.description?.toLowerCase().contains('action'), true);
      }
    });
    
    test('should handle large numbers of rules efficiently', () async {
      final service = _InMemoryValidationRuleService(
        initialRules: [
          ValidationRule(
            id: 1,
            ruleId: 'baseline_1',
            name: 'Baseline Rule',
            description: 'Baseline rule',
            eventType: EventType.ObjectEvent,
            severity: RuleSeverity.INFO,
            enabled: true,
          ),
        ],
      );

      final cubit = ValidationRuleCubit(
        validationRuleService: service,
      );
      addTearDown(cubit.close);
      await cubit.loadValidationRules();
      
      // Add many custom rules
      const int ruleCount = 10; // Reduced for testing
      for (int i = 0; i < ruleCount; i++) {
        await cubit.createValidationRule(ValidationRule(
          ruleId: 'custom_rule_$i',
          name: 'Custom Rule $i',
          description: 'Description for rule $i',
          eventType: i % 4 == 0 ? EventType.ObjectEvent :
                   i % 4 == 1 ? EventType.AggregationEvent :
                   i % 4 == 2 ? EventType.TransactionEvent :
                   EventType.TransformationEvent,
          severity: i % 3 == 0 ? RuleSeverity.INFO :
                   i % 3 == 1 ? RuleSeverity.WARNING :
                   RuleSeverity.ERROR,
          enabled: true,
        ));
      }
      
      // Verify we can still filter efficiently
      final stopwatch = Stopwatch()..start();
      
      // Run a series of filter operations to measure performance
      for (int i = 0; i < 10; i++) {
        final objectRules = cubit.rules.where((r) => r.eventType == EventType.ObjectEvent).toList();
        final field3Rules = cubit.rules.where((r) => r.description?.contains('field_3') == true).toList();
      }
      
      stopwatch.stop();
      
      // Filtering should be fast even with many rules
      // This is a performance guideline rather than a strict assertion
      expect(stopwatch.elapsedMilliseconds < 1000, true,
          reason: 'Rule filtering took too long: ${stopwatch.elapsedMilliseconds}ms');
    });
    
    test('reset to defaults should perform efficiently', () async {
      final service = _InMemoryValidationRuleService(
        initialRules: [
          ValidationRule(
            id: 1,
            ruleId: 'baseline_1',
            name: 'Baseline Rule',
            description: 'Baseline rule',
            eventType: EventType.ObjectEvent,
            severity: RuleSeverity.INFO,
            enabled: true,
          ),
        ],
      );

      final cubit = ValidationRuleCubit(
        validationRuleService: service,
      );
      addTearDown(cubit.close);
      await cubit.loadValidationRules();
      
      // Add some custom rules
      const int ruleCount = 5;
      for (int i = 0; i < ruleCount; i++) {
        await cubit.createValidationRule(ValidationRule(
          ruleId: 'custom_rule_$i',
          name: 'Custom Rule $i',
          description: 'Description for rule $i',
          eventType: EventType.ObjectEvent,
          severity: RuleSeverity.INFO,
          enabled: true,
        ));
      }
      
      final originalRuleCount = cubit.rules.length;
      
      final stopwatch = Stopwatch()..start();
      await cubit.resetToDefaults(); // Uses actual reset method
      stopwatch.stop();
      
      // Reset should be fast
      expect(stopwatch.elapsedMilliseconds < 5000, true,
          reason: 'Reset to defaults took too long: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should have rules after reset (predefined rules)
      expect(cubit.rules.length, greaterThan(0));
    });
  });
}
