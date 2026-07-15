part of 'operation_split_cubit.dart';

class OperationSplitState extends Equatable {
  const OperationSplitState({
    this.operationIds = const [],
    this.createdOperationId,
    this.isEmpty = false,
    this.isListLoading = true,
  });

  final List<String> operationIds;
  final String? createdOperationId;
  final bool isEmpty;
  final bool isListLoading;

  OperationSplitState copyWith({
    List<String>? operationIds,
    String? createdOperationId,
    bool? isEmpty,
    bool? isListLoading,
  }) =>
      OperationSplitState(
        operationIds: operationIds ?? this.operationIds,
        createdOperationId: createdOperationId ?? this.createdOperationId,
        isEmpty: isEmpty ?? this.isEmpty,
        isListLoading: isListLoading ?? this.isListLoading,
      );

  @override
  List<Object?> get props =>
      [operationIds, createdOperationId, isEmpty, isListLoading];
}
