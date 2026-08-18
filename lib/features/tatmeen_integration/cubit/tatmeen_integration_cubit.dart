import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';
import 'package:traqtrace_app/data/services/tatmeen_integration/tatmeen_integration_service.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';

class TatmeenIntegrationCubit extends Cubit<TatmeenIntegrationState> {
  TatmeenIntegrationCubit({required TatmeenIntegrationService service})
    : _service = service,
      super(const TatmeenIntegrationState());

  final TatmeenIntegrationService _service;
  int _requestGeneration = 0;
  bool _loading = false;
  bool _updating = false;
  bool _testing = false;

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (!force &&
        state.status == TatmeenIntegrationStatus.loaded &&
        state.settings != null) {
      return;
    }

    final generation = ++_requestGeneration;
    _loading = true;
    emit(
      state.copyWith(
        status: TatmeenIntegrationStatus.loading,
        clearError: true,
        clearConnectionTestResult: true,
      ),
    );

    try {
      final settings = await _service.fetchSettings();
      if (isClosed || generation != _requestGeneration) return;
      emit(
        state.copyWith(
          status: TatmeenIntegrationStatus.loaded,
          settings: settings,
          confirmedEnabled: settings.enabled,
          clearError: true,
        ),
      );
    } catch (e) {
      if (isClosed || generation != _requestGeneration) return;
      emit(
        state.copyWith(
          status: TatmeenIntegrationStatus.error,
          error: _messageFor(e),
        ),
      );
    } finally {
      _loading = false;
    }
  }

  Future<void> saveSettings(
    UpdateTatmeenIntegrationSettingsRequest request,
  ) async {
    if (_updating || isBusyExceptLoaded) return;

    final previous = state.settings;
    _updating = true;
    emit(
      state.copyWith(
        status: TatmeenIntegrationStatus.updating,
        clearError: true,
        clearConnectionTestResult: true,
      ),
    );

    try {
      final settings = await _service.updateSettings(request);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: TatmeenIntegrationStatus.loaded,
          settings: settings,
          confirmedEnabled: settings.enabled,
          clearError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: TatmeenIntegrationStatus.loaded,
          settings: previous,
          error: _messageFor(e),
        ),
      );
    } finally {
      _updating = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    await saveSettings(
      UpdateTatmeenIntegrationSettingsRequest(enabled: enabled),
    );
  }

  Future<void> testConnection() async {
    if (_testing || isBusyExceptLoaded) return;
    final settings = state.settings;
    if (settings == null || !settings.credentialsComplete) return;

    _testing = true;
    emit(
      state.copyWith(
        status: TatmeenIntegrationStatus.testingConnection,
        clearError: true,
        clearConnectionTestResult: true,
      ),
    );

    try {
      final result = await _service.testConnection();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: TatmeenIntegrationStatus.loaded,
          connectionTestResult: result,
          clearError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: TatmeenIntegrationStatus.loaded,
          error: _messageFor(e),
        ),
      );
    } finally {
      _testing = false;
    }
  }

  bool get isBusyExceptLoaded =>
      state.status == TatmeenIntegrationStatus.loading ||
      state.status == TatmeenIntegrationStatus.updating ||
      state.status == TatmeenIntegrationStatus.testingConnection;

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.getUserFriendlyMessage();
    }
    return error.toString();
  }
}
