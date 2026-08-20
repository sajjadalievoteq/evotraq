import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_state.dart';

class OperationSplitCubit extends Cubit<OperationSplitState> {
  OperationSplitCubit() : super(const OperationSplitState());

  void updateOperationIds(List<String> ids, {required bool isEmpty}) =>
      emit(state.copyWith(operationIds: ids, isEmpty: isEmpty));

  void setListLoading(bool loading) {
    if (state.isListLoading == loading) return;
    emit(state.copyWith(isListLoading: loading));
  }

  void setCreatedId(String? id) => emit(state.copyWith(createdOperationId: id));

  void clearCreatedId() => emit(state.copyWith(createdOperationId: null));
}
