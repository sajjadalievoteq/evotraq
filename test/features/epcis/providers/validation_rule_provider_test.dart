import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:traqtrace_app/data/services/epcis/validation_rule_service.dart';

import 'package:traqtrace_app/data/models/epcis/validation_rule.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';


@GenerateMocks([ValidationRuleService])
import 'validation_rule_provider_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ValidationRuleCubit cubit;
  late MockValidationRuleService mockService;
  

  group('ValidationRuleProvider Tests', () {
    setUp(() {
      mockService = MockValidationRuleService();
      
      
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

      cubit = ValidationRuleCubit(
        validationRuleService: mockService,

      );
    });

    tearDown(() async {
      await cubit.close();
    });
    
    test('should load predefined rules on initialization', () async {
      await cubit.loadValidationRules();
      
      
      expect(cubit.rules, isNotEmpty);
      expect(cubit.rules.any((r) => r.ruleId.contains('obj_action')), true);
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

      await cubit.loadValidationRules();
      
      
      final objectRules = cubit.getRulesByEventType(EventType.ObjectEvent);
      
      
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

      await cubit.loadValidationRules();
      
      
      final formatRules = cubit.getRulesByCategory('format');
      
      
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

      await cubit.loadValidationRules();
      
      
      final createdRule = await cubit.createValidationRule(testRule);
      expect(createdRule, isNotNull);
      
      
      if (createdRule?.id != null) {
        final updatedRule = createdRule!.copyWith(
          severity: RuleSeverity.ERROR,
        );
        
        
        final result = await cubit.updateValidationRule(createdRule.id!, updatedRule);
        expect(result, isNotNull);
        expect(result?.severity, RuleSeverity.ERROR);
      }
    });
  });
  
  group('ValidationRule model tests', () {
    test('should convert between JSON and model correctly', () {
      
      final rule = ValidationRule(
        ruleId: 'test_rule',
        name: 'Test Rule',
        description: 'This is a test rule',
        eventType: EventType.ObjectEvent,
        category: 'test',
        severity: RuleSeverity.WARNING,
        enabled: true,
      );
      
      
      final json = rule.toJson();
      
      
      final recreatedRule = ValidationRule.fromJson(json);
      
      
      expect(recreatedRule.ruleId, rule.ruleId);
      expect(recreatedRule.name, rule.name);
      expect(recreatedRule.description, rule.description);
      expect(recreatedRule.eventType, rule.eventType);
      expect(recreatedRule.category, rule.category);
      expect(recreatedRule.severity, rule.severity);
      expect(recreatedRule.enabled, rule.enabled);
    });
    
    test('should correctly determine severity properties', () {
      
      expect(RuleSeverity.INFO.displayName, 'Info');
      expect(RuleSeverity.WARNING.displayName, 'Warning');
      expect(RuleSeverity.ERROR.displayName, 'Error');
      
      
      expect(RuleSeverity.INFO.color, isNotNull);
      expect(RuleSeverity.WARNING.color, isNotNull);
      expect(RuleSeverity.ERROR.color, isNotNull);
      
      
      expect(RuleSeverity.INFO.iconAsset, isNotNull);
      expect(RuleSeverity.WARNING.iconAsset, isNotNull);
      expect(RuleSeverity.ERROR.iconAsset, isNotNull);
    });
  });
}
