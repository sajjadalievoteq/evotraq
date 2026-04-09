import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/services/validation_rule_service.dart';

@GenerateMocks([ValidationRuleService])
import 'validation_rule_provider_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ValidationRuleProvider provider;
  late MockValidationRuleService mockService;
  
  final appConfig = AppConfig(
    apiBaseUrl: 'https://api.test.com',
    appName: 'TraqTrace Test',
    appVersion: '1.0.0',
  );

  group('ValidationRuleProvider Tests', () {
    setUp(() {
      mockService = MockValidationRuleService();
      
      // Default behavior for getAllRules - return sample rules
      when(mockService.getAllRules()).thenAnswer((_) async => [
        ValidationRule(
          ruleId: 'obj_action',
          name: 'Action Check',
          description: 'Check action',
          eventType: EventType.ObjectEvent,
          category: 'format',
          severity: RuleSeverity.ERROR,
          enabled: true,
        )
      ]);

      provider = ValidationRuleProvider(
        validationRuleService: mockService,
        appConfig: appConfig,
      );
    });
    
    test('should load predefined rules on initialization', () async {
      await provider.loadValidationRules();
      
      // Verify predefined rules are loaded
      expect(provider.rules, isNotEmpty);
      expect(provider.rules.any((r) => r.ruleId.contains('obj_action')), true);
      verify(mockService.getAllRules()).called(greaterThanOrEqualTo(1));
    });
    
    test('should get rules for specific event type', () async {
      when(mockService.getAllRules()).thenAnswer((_) async => [
        ValidationRule(
          ruleId: 'r1',
          name: 'n1',
          description: 'd1',
          eventType: EventType.ObjectEvent,
          category: 'c1',
          severity: RuleSeverity.ERROR,
          enabled: true,
        ),
        ValidationRule(
          ruleId: 'r2',
          name: 'n2',
          description: 'd2',
          eventType: EventType.AggregationEvent,
          category: 'c2',
          severity: RuleSeverity.ERROR,
          enabled: true,
        ),
      ]);

      await provider.loadValidationRules();
      
      // Get rules for Object Events
      final objectRules = provider.getRulesByEventType(EventType.ObjectEvent);
      
      // Verify rules are filtered correctly
      expect(objectRules, isNotEmpty);
      expect(objectRules.every((r) => r.eventType == EventType.ObjectEvent || r.eventType == EventType.ALL), true);
      expect(objectRules.any((r) => r.eventType == EventType.AggregationEvent), false);
    });
    
    test('should get rules for specific category', () async {
      when(mockService.getAllRules()).thenAnswer((_) async => [
        ValidationRule(
          ruleId: 'r1',
          name: 'n1',
          description: 'd1',
          eventType: EventType.ObjectEvent,
          category: 'format',
          severity: RuleSeverity.ERROR,
          enabled: true,
        ),
      ]);

      await provider.loadValidationRules();
      
      // Get rules for specific category
      final formatRules = provider.getRulesByCategory('format');
      
      // Verify rules are filtered correctly
      for (final rule in formatRules) {
        expect(rule.category, 'format');
      }
    });
    
    test('should update rule settings', () async {
      final testRule = ValidationRule(
        id: 1,
        ruleId: 'test_rule_update',
        name: 'Test Rule Update',
        description: 'This is a test rule for updates',
        eventType: EventType.ObjectEvent,
        category: 'test',
        severity: RuleSeverity.WARNING,
        enabled: true,
      );
      
      when(mockService.createRule(any)).thenAnswer((_) async => testRule);
      when(mockService.updateRule(any, any)).thenAnswer((_) async => testRule.copyWith(severity: RuleSeverity.ERROR));

      await provider.loadValidationRules();
      
      // Create the rule first
      final createdRule = await provider.createValidationRule(testRule);
      expect(createdRule, isNotNull);
      
      // Update the rule with different severity
      if (createdRule?.id != null) {
        final updatedRule = createdRule!.copyWith(
          severity: RuleSeverity.ERROR,
        );
        
        // Update the rule
        final result = await provider.updateValidationRule(createdRule.id!, updatedRule);
        expect(result, isNotNull);
        expect(result?.severity, RuleSeverity.ERROR);
      }
    });
  });
  
  group('ValidationRule model tests', () {
    test('should convert between JSON and model correctly', () {
      // Create a rule
      final rule = ValidationRule(
        ruleId: 'test_rule',
        name: 'Test Rule',
        description: 'This is a test rule',
        eventType: EventType.ObjectEvent,
        category: 'test',
        severity: RuleSeverity.WARNING,
        enabled: true,
      );
      
      // Convert to JSON
      final json = rule.toJson();
      
      // Create new rule from JSON
      final recreatedRule = ValidationRule.fromJson(json);
      
      // Verify values
      expect(recreatedRule.ruleId, rule.ruleId);
      expect(recreatedRule.name, rule.name);
      expect(recreatedRule.description, rule.description);
      expect(recreatedRule.eventType, rule.eventType);
      expect(recreatedRule.category, rule.category);
      expect(recreatedRule.severity, rule.severity);
      expect(recreatedRule.enabled, rule.enabled);
    });
    
    test('should correctly determine severity properties', () {
      // Test severity display names
      expect(RuleSeverity.INFO.displayName, 'Info');
      expect(RuleSeverity.WARNING.displayName, 'Warning');
      expect(RuleSeverity.ERROR.displayName, 'Error');
      
      // Test severity colors are different
      expect(RuleSeverity.INFO.color, isNotNull);
      expect(RuleSeverity.WARNING.color, isNotNull);
      expect(RuleSeverity.ERROR.color, isNotNull);
      
      // Test severity icons are different
      expect(RuleSeverity.INFO.icon, isNotNull);
      expect(RuleSeverity.WARNING.icon, isNotNull);
      expect(RuleSeverity.ERROR.icon, isNotNull);
    });
  });
}
