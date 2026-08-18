import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';

enum TatmeenIntegrationStatus {
  initial,
  loading,
  loaded,
  updating,
  testingConnection,
  error,
}

class TatmeenIntegrationState extends Equatable {
  const TatmeenIntegrationState({
    this.status = TatmeenIntegrationStatus.initial,
    this.settings,
    this.confirmedEnabled = false,
    this.connectionTestResult,
    this.error,
  });

  final TatmeenIntegrationStatus status;
  final TatmeenIntegrationSettings? settings;
  final bool confirmedEnabled;
  final TatmeenConnectionTestResult? connectionTestResult;
  final String? error;

  bool get isEnabled => settings?.enabled ?? confirmedEnabled;

  bool get isBusy =>
      status == TatmeenIntegrationStatus.loading ||
      status == TatmeenIntegrationStatus.updating ||
      status == TatmeenIntegrationStatus.testingConnection;

  TatmeenIntegrationState copyWith({
    TatmeenIntegrationStatus? status,
    TatmeenIntegrationSettings? settings,
    bool? confirmedEnabled,
    TatmeenConnectionTestResult? connectionTestResult,
    String? error,
    bool clearError = false,
    bool clearConnectionTestResult = false,
  }) {
    return TatmeenIntegrationState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      confirmedEnabled: confirmedEnabled ?? this.confirmedEnabled,
      connectionTestResult: clearConnectionTestResult
          ? null
          : (connectionTestResult ?? this.connectionTestResult),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    settings,
    confirmedEnabled,
    connectionTestResult,
    error,
  ];
}
