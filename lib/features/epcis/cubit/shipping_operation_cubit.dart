import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/models/operations/shipping_models.dart';
import 'package:traqtrace_app/features/epcis/services/operations/shipping_operation_service.dart';

class ShippingOperationState extends Equatable {
  final List<ShippingResponse> operations;
  final ShippingResponse? selectedOperation;
  final ShippingResponse? lastCreatedOperation;
  final bool loading;
  final String? error;

  const ShippingOperationState({
    this.operations = const [],
    this.selectedOperation,
    this.lastCreatedOperation,
    this.loading = false,
    this.error,
  });

  ShippingOperationState copyWith({
    List<ShippingResponse>? operations,
    ShippingResponse? selectedOperation,
    ShippingResponse? lastCreatedOperation,
    bool? loading,
    String? error,
  }) {
    return ShippingOperationState(
      operations: operations ?? this.operations,
      selectedOperation: selectedOperation ?? this.selectedOperation,
      lastCreatedOperation: lastCreatedOperation ?? this.lastCreatedOperation,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    operations,
    selectedOperation,
    lastCreatedOperation,
    loading,
    error,
  ];
}

class ShippingOperationCubit extends Cubit<ShippingOperationState> {
  final ShippingOperationService _service;

  ShippingOperationCubit(this._service) : super(const ShippingOperationState());

  void clearError() {
    emit(state.copyWith(error: null));
  }

  Future<void> loadOperations({int page = 0, int size = 20}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final operations = await _service.getAllShippingOperations(
        page: page,
        size: size,
      );
      emit(state.copyWith(operations: operations, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> getOperation(String operationId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final operation = await _service.getShippingOperation(operationId);
      emit(
        state.copyWith(
          selectedOperation: operation,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<ShippingResponse> createShippingOperation(
    ShippingRequest shippingRequest,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final response = await _service.createShippingOperation(shippingRequest);
      final updatedOperations = response.shippingOperationId != null
          ? [response, ...state.operations]
          : state.operations;
      emit(
        state.copyWith(
          operations: updatedOperations,
          lastCreatedOperation: response,
          loading: false,
          error: null,
        ),
      );
      return response;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<ShippingResponse> validateShippingRequest(
    ShippingRequest shippingRequest,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final response = await _service.validateShippingRequest(shippingRequest);
      emit(state.copyWith(loading: false, error: null));
      return response;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadOperationsByReference(String reference) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final operations = await _service.getShippingOperationsByReference(
        reference,
      );
      emit(state.copyWith(operations: operations, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadOperationsByDestination(String destinationGLN) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final operations = await _service.getShippingOperationsByDestination(
        destinationGLN,
      );
      emit(state.copyWith(operations: operations, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadOperationsBySource(String sourceGLN) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final operations = await _service.getShippingOperationsBySource(
        sourceGLN,
      );
      emit(state.copyWith(operations: operations, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadOperationsForEPC(String epc) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final operations = await _service.getShippingOperationsForEPC(epc);
      emit(state.copyWith(operations: operations, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
