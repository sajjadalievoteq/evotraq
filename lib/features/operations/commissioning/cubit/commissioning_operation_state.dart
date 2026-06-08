import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';

class CommissioningOperationState extends Equatable {
  /// Last successfully created/loaded commissioning response.
  final CommissioningResponse? lastResult;

  /// Whether an async operation is in progress.
  final bool loading;

  /// Non-null when the most recent operation failed.
  final String? error;

  const CommissioningOperationState({
    this.lastResult,
    this.loading = false,
    this.error,
  });

  CommissioningOperationState copyWith({
    CommissioningResponse? lastResult,
    bool? loading,
    String? error,
  }) {
    return CommissioningOperationState(
      lastResult: lastResult ?? this.lastResult,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [lastResult, loading, error];
}
