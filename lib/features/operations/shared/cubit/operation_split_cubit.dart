import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'operation_split_state.dart';

class OperationSplitCubit extends Cubit<OperationSplitState> {
  OperationSplitCubit() : super(const OperationSplitState());

  void updateOperationIds(List<String> ids, {required bool isEmpty}) =>
      emit(state.copyWith(operationIds: ids, isEmpty: isEmpty));

  void setCreatedId(String? id) =>
      emit(state.copyWith(createdOperationId: id));

  void clearCreatedId() =>
      emit(state.copyWith(createdOperationId: null));
}
