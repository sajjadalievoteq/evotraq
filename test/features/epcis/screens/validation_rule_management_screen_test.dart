import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/theme/theme_provider.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/screens/validation_rule_management_screen.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/models/auth_models.dart';
import 'package:mockito/mockito.dart';

class _MockValidationRuleCubit extends Mock implements ValidationRuleCubit {}

class _MockAuthCubit extends Mock implements AuthCubit {}

class _MockThemeCubit extends Mock implements ThemeCubit {}

class _MockSystemSettingsCubit extends Mock implements SystemSettingsCubit {}

void main() {
  testWidgets('ValidationRuleManagementScreen shows rules and UI elements', (
    WidgetTester tester,
  ) async {
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

    final validationRuleState = ValidationRuleState(
      validationRules: testRules,
      isLoading: false,
      error: null,
    );

    final mockValidationRuleCubit = _MockValidationRuleCubit();
    when(mockValidationRuleCubit.state).thenReturn(validationRuleState);
    when(
      mockValidationRuleCubit.stream,
    ).thenAnswer((_) => const Stream<ValidationRuleState>.empty());
    when(mockValidationRuleCubit.getPredefinedRules()).thenReturn(const []);

    final mockAuthCubit = _MockAuthCubit();
    when(mockAuthCubit.state).thenReturn(
      AuthState(
        status: AuthStatus.authenticated,
        user: User(
          id: 1,
          username: 'test',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          role: 'ADMIN',
          enabled: true,
        ),
      ),
    );
    when(
      mockAuthCubit.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());

    final mockThemeCubit = _MockThemeCubit();
    when(mockThemeCubit.state).thenReturn(const ThemeState(isDarkMode: false));
    when(
      mockThemeCubit.stream,
    ).thenAnswer((_) => const Stream<ThemeState>.empty());

    final mockSystemSettingsCubit = _MockSystemSettingsCubit();
    when(
      mockSystemSettingsCubit.state,
    ).thenReturn(SystemSettingsState.initial());
    when(
      mockSystemSettingsCubit.stream,
    ).thenAnswer((_) => const Stream<SystemSettingsState>.empty());

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
            BlocProvider<SystemSettingsCubit>.value(
              value: mockSystemSettingsCubit,
            ),
            BlocProvider<ValidationRuleCubit>.value(
              value: mockValidationRuleCubit,
            ),
          ],
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
