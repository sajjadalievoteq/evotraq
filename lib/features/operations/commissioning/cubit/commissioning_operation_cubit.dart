import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_state.dart';

class CommissioningOperationCubit extends Cubit<CommissioningOperationState> {
  final CommissioningOperationService _service;

  CommissioningOperationCubit(this._service)
      : super(const CommissioningOperationState());

  void clearError() => emit(state.copyWith(error: null));

  void reset() => emit(const CommissioningOperationState());

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
