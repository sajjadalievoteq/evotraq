import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';
import 'package:traqtrace_app/data/services/tatmeen_integration/tatmeen_integration_service.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_cubit.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';

class _MockTatmeenIntegrationService extends Mock
    implements TatmeenIntegrationService {}

void main() {
  late _MockTatmeenIntegrationService service;

  const disabled = TatmeenIntegrationSettings(enabled: false);
  const configured = TatmeenIntegrationSettings(
    enabled: true,
    username: 'tat-user',
    passwordConfigured: true,
    apiKeyConfigured: true,
  );

  setUpAll(() {
    registerFallbackValue(const UpdateTatmeenIntegrationSettingsRequest());
  });

  setUp(() {
    service = _MockTatmeenIntegrationService();
  });

  blocTest<TatmeenIntegrationCubit, TatmeenIntegrationState>(
    'load emits loading then loaded',
    build: () {
      when(() => service.fetchSettings()).thenAnswer((_) async => disabled);
      return TatmeenIntegrationCubit(service: service);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<TatmeenIntegrationState>().having(
        (s) => s.status,
        'status',
        TatmeenIntegrationStatus.loading,
      ),
      isA<TatmeenIntegrationState>()
          .having((s) => s.status, 'status', TatmeenIntegrationStatus.loaded)
          .having((s) => s.isEnabled, 'enabled', false),
    ],
  );

  blocTest<TatmeenIntegrationCubit, TatmeenIntegrationState>(
    'setEnabled restores confirmed value when update fails',
    build: () {
      when(() => service.fetchSettings()).thenAnswer((_) async => disabled);
      when(
        () => service.updateSettings(any()),
      ).thenThrow(ApiException(statusCode: 403, message: 'Forbidden'));
      return TatmeenIntegrationCubit(service: service);
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.setEnabled(true);
    },
    expect: () => [
      isA<TatmeenIntegrationState>().having(
        (s) => s.status,
        'status',
        TatmeenIntegrationStatus.loading,
      ),
      isA<TatmeenIntegrationState>().having(
        (s) => s.status,
        'status',
        TatmeenIntegrationStatus.loaded,
      ),
      isA<TatmeenIntegrationState>().having(
        (s) => s.status,
        'status',
        TatmeenIntegrationStatus.updating,
      ),
      isA<TatmeenIntegrationState>()
          .having((s) => s.status, 'status', TatmeenIntegrationStatus.loaded)
          .having((s) => s.isEnabled, 'enabled', false)
          .having((s) => s.error, 'error', isNotNull),
    ],
  );

  blocTest<TatmeenIntegrationCubit, TatmeenIntegrationState>(
    'duplicate toggle requests are ignored while updating',
    build: () {
      when(() => service.fetchSettings()).thenAnswer((_) async => disabled);
      when(() => service.updateSettings(any())).thenAnswer((invocation) async {
        final request =
            invocation.positionalArguments.first
                as UpdateTatmeenIntegrationSettingsRequest;
        if (request.enabled == true) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return configured;
        }
        return disabled;
      });
      return TatmeenIntegrationCubit(service: service);
    },
    act: (cubit) async {
      await cubit.load();
      final first = cubit.setEnabled(true);
      final second = cubit.setEnabled(false);
      await Future.wait([first, second]);
    },
    verify: (_) {
      verify(
        () => service.updateSettings(
          const UpdateTatmeenIntegrationSettingsRequest(enabled: true),
        ),
      ).called(1);
      verifyNever(
        () => service.updateSettings(
          const UpdateTatmeenIntegrationSettingsRequest(enabled: false),
        ),
      );
    },
  );

  blocTest<TatmeenIntegrationCubit, TatmeenIntegrationState>(
    'testConnection stores sanitized result',
    build: () {
      when(() => service.fetchSettings()).thenAnswer((_) async => configured);
      when(() => service.testConnection()).thenAnswer(
        (_) async => const TatmeenConnectionTestResult(
          success: true,
          message: 'Connection successful',
        ),
      );
      return TatmeenIntegrationCubit(service: service);
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.testConnection();
    },
    expect: () => [
      isA<TatmeenIntegrationState>(),
      isA<TatmeenIntegrationState>(),
      isA<TatmeenIntegrationState>().having(
        (s) => s.status,
        'status',
        TatmeenIntegrationStatus.testingConnection,
      ),
      isA<TatmeenIntegrationState>()
          .having((s) => s.connectionTestResult?.success, 'success', true)
          .having(
            (s) => s.connectionTestResult?.message,
            'message',
            'Connection successful',
          ),
    ],
  );
}
