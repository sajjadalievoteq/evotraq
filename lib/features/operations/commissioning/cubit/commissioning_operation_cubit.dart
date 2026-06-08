import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_state.dart';

/// BLoC cubit for the commissioning workflow.
///
/// Wraps [CommissioningOperationService] and exposes loading/error state to
/// the UI. The screen should use [BlocBuilder] to react to state changes and
/// [BlocListener] to react to one-time events (navigation, snackbars).
class CommissioningOperationCubit extends Cubit<CommissioningOperationState> {
  final CommissioningOperationService _service;

  CommissioningOperationCubit(this._service)
      : super(const CommissioningOperationState());

  /// Clear any displayed error without triggering a reload.
  void clearError() => emit(state.copyWith(error: null));

  /// Reset to initial state (e.g. when navigating away).
  void reset() => emit(const CommissioningOperationState());

  /// Execute a bulk commissioning operation.
  ///
  /// On success, [CommissioningOperationState.lastResult] is populated with the
  /// full response including the EPCIS event ID and per-item outcomes.
  ///
  /// On failure, [CommissioningOperationState.error] is set with the error
  /// message. The loading indicator is always cleared.
  Future<CommissioningResponse?> commissionBulk(
      CommissioningRequest request) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final response =
          await _service.createCommissioningOperation(request);
      emit(state.copyWith(lastResult: response, loading: false, error: null));
      return response;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }
}
