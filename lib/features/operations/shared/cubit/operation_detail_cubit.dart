import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/reference_data_service.dart';

part 'operation_detail_state.dart';

class OperationDetailCubit<T> extends Cubit<OperationDetailState<T>> {
  OperationDetailCubit({
    required Future<T> Function(String id) fetchDetail,
    required String fallbackErrorMessage,
    ReferenceDataService? referenceDataService,
  }) : _fetchDetail = fetchDetail,
       _fallbackErrorMessage = fallbackErrorMessage,
       _referenceDataService = referenceDataService,
       super(OperationDetailState<T>());

  final Future<T> Function(String id) _fetchDetail;
  final String _fallbackErrorMessage;
  final ReferenceDataService? _referenceDataService;

  Future<GLN?> resolveGln(String code) {
    return _referenceDataService!.resolveGln(code);
  }

  Future<void> load(String id) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        clearOperation: true,
      ),
    );
    try {
      final result = await _fetchDetail(id);
      emit(
        state.copyWith(
          isLoading: false,
          operation: result,
          clearErrorMessage: true,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.getUserFriendlyMessage(),
          clearOperation: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _fallbackErrorMessage,
          clearOperation: true,
        ),
      );
    }
  }

  void setOperation(T updated) {
    emit(state.copyWith(operation: updated, clearErrorMessage: true));
  }
}
