import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/services/operations/receiving/receiving_operation_service.dart';

part 'receiving_acceptance_state.dart';

class ReceivingAcceptanceCubit extends Cubit<ReceivingAcceptanceState> {
  ReceivingAcceptanceCubit({required ReceivingOperationService service})
      : _service = service,
        super(const ReceivingAcceptanceState());

  final ReceivingOperationService _service;

  Future<void> acceptGoods({
    required String receivingEventId,
    required String receiverGln,
  }) async {
    emit(state.copyWith(status: ReceivingAcceptanceStatus.loading, clearError: true));
    try {
      final updated = await _service.acceptGoods(
        receivingEventId: receivingEventId,
        receiverGln: receiverGln,
      );
      emit(state.copyWith(
        status: ReceivingAcceptanceStatus.success,
        updatedOperation: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReceivingAcceptanceStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void reset() {
    if (state.status == ReceivingAcceptanceStatus.idle) return;
    emit(state.copyWith(
      status: ReceivingAcceptanceStatus.idle,
      clearError: true,
      clearUpdatedOperation: true,
    ));
  }
}
