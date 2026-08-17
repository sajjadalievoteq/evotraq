import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_state.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';

class CommissioningOperationCubit extends Cubit<CommissioningOperationState> {
  CommissioningOperationCubit({
    required CommissioningOperationService commissioningService,
    required PharmaceuticalService pharmaceuticalService,
  }) : _service = commissioningService,
       _pharmaceuticalService = pharmaceuticalService,
       super(const CommissioningOperationState());

  final CommissioningOperationService _service;
  final PharmaceuticalService _pharmaceuticalService;

  void clearError() => emit(state.copyWith(clearError: true));

  void reset() {
    emit(const CommissioningOperationState());
  }

  /// True when the GTIN has a pharmaceutical extension (expiry required on commission).
  Future<bool> onPharmaGtinIdentified(String gtinCode) async {
    try {
      final ext = await _pharmaceuticalService.getExtensionByGtinCode(gtinCode);
      return ext != null && ext.gtinId > 0;
    } catch (_) {
      return false;
    }
  }

  Future<CommissioningResponse?> commissionBulk(
    CommissioningRequest request,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final response = await _service.createCommissioningOperation(request);
      emit(
        state.copyWith(lastResult: response, loading: false, clearError: true),
      );
      return response;
    } on ApiException {
      emit(state.copyWith(loading: false));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }

  Future<CommissioningResponse?> commissionSscc(
    SsccCommissioningRequest request,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final response = await _service.createSsccCommissioningOperation(request);
      emit(
        state.copyWith(lastResult: response, loading: false, clearError: true),
      );
      return response;
    } on ApiException {
      emit(state.copyWith(loading: false));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }
}
