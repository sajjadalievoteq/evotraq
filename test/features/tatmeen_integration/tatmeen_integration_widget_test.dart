import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';
import 'package:traqtrace_app/data/services/tatmeen_integration/tatmeen_integration_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_cubit.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/utils/tatmeen_integration_sections.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_detail_pane.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_configuration_body.dart';

class _MockTatmeenIntegrationService extends Mock
    implements TatmeenIntegrationService {}

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _HarnessCubit extends TatmeenIntegrationCubit {
  _HarnessCubit(TatmeenIntegrationService service) : super(service: service);

  void emitState(TatmeenIntegrationState state) => emit(state);
}

void main() {
  late _MockTatmeenIntegrationService service;
  late _HarnessCubit cubit;
  late _MockAuthCubit authCubit;

  setUp(() {
    service = _MockTatmeenIntegrationService();
    cubit = _HarnessCubit(service);
    authCubit = _MockAuthCubit();
    if (getIt.isRegistered<TatmeenIntegrationCubit>()) {
      getIt.unregister<TatmeenIntegrationCubit>();
    }
    getIt.registerFactory<TatmeenIntegrationCubit>(() => cubit);
  });

  tearDown(() async {
    await cubit.close();
    if (getIt.isRegistered<TatmeenIntegrationCubit>()) {
      getIt.unregister<TatmeenIntegrationCubit>();
    }
  });

  Widget wrap(Widget child, {bool isAdmin = true}) {
    final authState = AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: 1,
        username: isAdmin ? 'admin' : 'maker',
        email: 'test@traqtrace.com',
        firstName: 'Test',
        lastName: 'User',
        role: isAdmin ? 'ADMIN' : 'MANUFACTURER',
        enabled: true,
      ),
    );
    when(() => authCubit.state).thenReturn(authState);
    whenListen(
      authCubit,
      Stream<AuthState>.value(authState),
      initialState: authState,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<TatmeenIntegrationCubit>.value(value: cubit),
        BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: MaterialApp(
        theme: TraqTheme.light(),
        home: Scaffold(body: child),
      ),
    );
  }

  TatmeenDetailPane buildDetailPane({bool canUpdate = true}) {
    return TatmeenDetailPane(
      state: cubit.state,
      canUpdate: canUpdate,
      selectedSection: TatmeenIntegrationSections.configurations,
      onToggle: (_) {},
      onRetry: () {},
      onSaveCredentials: (_) async => true,
      onRemovePassword: () async {},
      onRemoveApiKey: () async {},
      onTestConnection: () {},
    );
  }

  testWidgets('detail pane shows disabled state and credentials content', (
    tester,
  ) async {
    cubit.emitState(
      const TatmeenIntegrationState(
        status: TatmeenIntegrationStatus.loaded,
        settings: TatmeenIntegrationSettings(enabled: false),
        confirmedEnabled: false,
      ),
    );

    await tester.pumpWidget(
      wrap(SingleChildScrollView(child: buildDetailPane())),
    );

    expect(find.text('Credentials'), findsOneWidget);
    expect(find.text('Email notifications'), findsOneWidget);
    expect(find.text('In-app alerts'), findsNothing);
    expect(find.text('Alert emails'), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('configured password shows indicator not prefilled value', (
    tester,
  ) async {
    cubit.emitState(
      const TatmeenIntegrationState(
        status: TatmeenIntegrationStatus.loaded,
        settings: TatmeenIntegrationSettings(
          enabled: false,
          username: 'tat-user',
          passwordConfigured: true,
          apiKeyConfigured: true,
          apiKeyHint: '••••1234',
        ),
        confirmedEnabled: false,
      ),
    );

    await tester.pumpWidget(
      wrap(SingleChildScrollView(child: buildDetailPane())),
    );

    expect(find.text('Password configured'), findsOneWidget);
    expect(find.text('••••1234'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);
  });

  testWidgets('non-admin sees read-only credentials note', (tester) async {
    cubit.emitState(
      const TatmeenIntegrationState(
        status: TatmeenIntegrationStatus.loaded,
        settings: TatmeenIntegrationSettings(enabled: false),
        confirmedEnabled: false,
      ),
    );

    await tester.pumpWidget(
      wrap(SingleChildScrollView(child: buildDetailPane(canUpdate: false))),
    );

    expect(
      find.text('Credential configuration is restricted to administrators.'),
      findsOneWidget,
    );
  });

  testWidgets('responsive body renders row on desktop width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    cubit.emitState(
      const TatmeenIntegrationState(
        status: TatmeenIntegrationStatus.loaded,
        settings: TatmeenIntegrationSettings(enabled: true),
        confirmedEnabled: true,
      ),
    );

    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 1200,
          height: 700,
          child: SingleChildScrollView(
            child: TatmeenConfigurationBody(
              canUpdate: true,
              selectedSection: TatmeenIntegrationSections.configurations,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Row), findsWidgets);
    expect(find.text('Integration'), findsOneWidget);
    expect(find.text('Credentials'), findsOneWidget);
    expect(find.text('Email notifications'), findsOneWidget);
  });
}
