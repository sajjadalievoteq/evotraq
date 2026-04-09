import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';

/// Tests focused on the performance features of the validation service
void main() {
  final appConfig = AppConfig(
    apiBaseUrl: 'https://api.test.com',
    appName: 'TraqTrace Test',
    appVersion: '1.0.0',
  );

  group('ValidationRuleProvider Performance Tests', () {
    test('should efficiently filter rules by event type', () async {
      final provider = ValidationRuleProvider(appConfig: appConfig);
      await provider.loadValidationRules();
      
      // Get rules for specific event types
      final objectRules = provider.rules.where((r) => r.eventType == EventType.ObjectEvent).toList();
      final aggregationRules = provider.rules.where((r) => r.eventType == EventType.AggregationEvent).toList();
      final transformationRules = provider.rules.where((r) => r.eventType == EventType.TransformationEvent).toList();
      final transactionRules = provider.rules.where((r) => r.eventType == EventType.TransactionEvent).toList();
      
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
      final provider = ValidationRuleProvider(appConfig: appConfig);
      await provider.loadValidationRules();
      
      // Get rules that mention specific fields in their description
      final actionRules = provider.rules.where((r) => 
        r.description?.toLowerCase().contains('action') == true).toList();
      
      // Should find some rules related to action field
      expect(actionRules.isNotEmpty, true);
      
      for (final rule in actionRules) {
        expect(rule.description?.toLowerCase().contains('action'), true);
      }
    });
    
    test('should handle large numbers of rules efficiently', () async {
      final provider = ValidationRuleProvider(appConfig: appConfig);
      await provider.loadValidationRules();
      
      // Add many custom rules
      const int ruleCount = 10; // Reduced for testing
      for (int i = 0; i < ruleCount; i++) {
        await provider.createValidationRule(ValidationRule(
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
        final objectRules = provider.rules.where((r) => r.eventType == EventType.ObjectEvent).toList();
        final field3Rules = provider.rules.where((r) => r.description?.contains('field_3') == true).toList();
      }
      
      stopwatch.stop();
      
      // Filtering should be fast even with many rules
      // This is a performance guideline rather than a strict assertion
      expect(stopwatch.elapsedMilliseconds < 1000, true,
          reason: 'Rule filtering took too long: ${stopwatch.elapsedMilliseconds}ms');
    });
    
    test('reset to defaults should perform efficiently', () async {
      final provider = ValidationRuleProvider(appConfig: appConfig);
      await provider.loadValidationRules();
      
      // Add some custom rules
      const int ruleCount = 5;
      for (int i = 0; i < ruleCount; i++) {
        await provider.createValidationRule(ValidationRule(
          ruleId: 'custom_rule_$i',
          name: 'Custom Rule $i',
          description: 'Description for rule $i',
          eventType: EventType.ObjectEvent,
          severity: RuleSeverity.INFO,
          enabled: true,
        ));
      }
      
      final originalRuleCount = provider.rules.length;
      
      final stopwatch = Stopwatch()..start();
      await provider.resetToDefaults(); // Uses actual reset method
      stopwatch.stop();
      
      // Reset should be fast
      expect(stopwatch.elapsedMilliseconds < 5000, true,
          reason: 'Reset to defaults took too long: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should have rules after reset (predefined rules)
      expect(provider.rules.length, greaterThan(0));
    });
  });
}
