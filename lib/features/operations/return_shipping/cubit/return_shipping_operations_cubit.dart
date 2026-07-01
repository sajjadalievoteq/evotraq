import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'return_shipping_operations_state.dart';

class ReturnShippingOperationsCubit extends Cubit<ReturnShippingOperationsState> {
  ReturnShippingOperationsCubit() : super(const ReturnShippingOperationsState());

  void updateOperationIds(List<String> ids, {required bool isEmpty}) =>
      emit(state.copyWith(operationIds: ids, isEmpty: isEmpty));

  void setCreatedId(String? id) =>
      emit(state.copyWith(createdOperationId: id));

  void clearCreatedId() =>
      emit(state.copyWith(createdOperationId: null));
}
