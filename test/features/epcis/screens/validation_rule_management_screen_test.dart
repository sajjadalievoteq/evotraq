import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/features/epcis/models/validation_rule.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/screens/validation_rule_management_screen.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'validation_rule_management_screen_test.mocks.dart';

@GenerateMocks([
  ValidationRuleCubit,
  AuthCubit,
  ThemeCubit,
  SystemSettingsCubit,
])
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

    final mockValidationRuleCubit = MockValidationRuleCubit();
    when(mockValidationRuleCubit.state).thenReturn(validationRuleState);
    when(
      mockValidationRuleCubit.stream,
    ).thenAnswer((_) => Stream<ValidationRuleState>.value(validationRuleState));
    when(mockValidationRuleCubit.getPredefinedRules()).thenReturn(const []);

    final mockAuthCubit = MockAuthCubit();
    final authState = AuthState(
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
    );
    when(mockAuthCubit.state).thenReturn(authState);
    when(
      mockAuthCubit.stream,
    ).thenAnswer((_) => Stream<AuthState>.value(authState));

    final mockThemeCubit = MockThemeCubit();
    const themeState = ThemeState(isDarkMode: false);
    when(mockThemeCubit.state).thenReturn(themeState);
    when(
      mockThemeCubit.stream,
    ).thenAnswer((_) => Stream<ThemeState>.value(themeState));

    final mockSystemSettingsCubit = MockSystemSettingsCubit();
    final systemSettingsState = SystemSettingsState.initial();
    when(
      mockSystemSettingsCubit.state,
    ).thenReturn(systemSettingsState);
    when(
      mockSystemSettingsCubit.stream,
    ).thenAnswer((_) => Stream<SystemSettingsState>.value(systemSettingsState));

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
    expect(find.textContaining('Validation Rule Management'), findsOneWidget);

    // Verify UI controls
    expect(find.byType(TextField), findsOneWidget); // Search field
    expect(find.byType(FloatingActionButton), findsOneWidget); // Main FAB menu button

    // Verify rules list displays
    expect(find.byType(Card), findsWidgets);
    expect(find.textContaining('Rule'), findsWidgets);

    // Verify severity indicators (chips or icons)
    expect(find.text('Error'), findsWidgets);
    expect(find.text('Warning'), findsWidgets);
    expect(find.text('Info'), findsWidgets);
  });
}
