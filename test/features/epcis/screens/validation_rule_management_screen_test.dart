import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/screens/validation_rule_management_screen.dart';

void main() {
  testWidgets('ValidationRuleManagementScreen shows rules and UI elements', (WidgetTester tester) async {
    // Set up test data
    final testRules = [
      ValidationRule(
        ruleId: '1',
        name: 'Test Rule 1',
        description: 'A test rule',
        eventType: EventType.ObjectEvent,
        severity: RuleSeverity.ERROR,
        enabled: true,
      ),
      ValidationRule(
        ruleId: '2',
        name: 'Test Rule 2',
        description: 'Another test rule',
        eventType: EventType.AggregationEvent,
        severity: RuleSeverity.WARNING,
        enabled: true,
      ),
      ValidationRule(
        ruleId: '3',
        name: 'Disabled Rule',
        description: 'A disabled rule',
        eventType: EventType.TransactionEvent,
        severity: RuleSeverity.INFO,
        enabled: false,
      ),
    ];
    
    // Create a simplified mock version of the provider
    final mockRuleProvider = TestValidationRuleProvider(testRules);
    
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ValidationRuleProvider>.value(
          value: mockRuleProvider,
          child: const ValidationRuleManagementScreen(),
        ),
      ),
    );
    
    // Wait for widget to build
    await tester.pumpAndSettle();
    
    // Verify screen title
    expect(find.textContaining('Validation Rules'), findsOneWidget);
    
    // Verify UI controls
    expect(find.byType(TextField), findsOneWidget); // Search field
    expect(find.byIcon(Icons.add), findsOneWidget); // Add button
    
    // Verify rules list displays
    expect(find.byType(ListTile), findsWidgets);
    expect(find.textContaining('Rule'), findsWidgets);
    
    // Verify severity indicators (chips or icons)
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Warning'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget);
  });
}

/// A simplified test provider for validation rules
class TestValidationRuleProvider extends ValidationRuleProvider {
  final List<ValidationRule> testRules;
  
  TestValidationRuleProvider(this.testRules) : super(
    appConfig: AppConfig(
      apiBaseUrl: 'https://api.test.com',
      appName: 'TraqTrace Test',
      appVersion: '1.0.0',
    ),
  );
  
  @override
  List<ValidationRule> get rules => testRules;
  
  @override
  List<ValidationRule> get validationRules => testRules;
  
  @override
  bool get loading => false;
  
  @override
  String? get error => null;
}
