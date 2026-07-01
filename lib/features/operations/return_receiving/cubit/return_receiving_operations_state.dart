part of 'return_receiving_operations_cubit.dart';

class ReturnReceivingOperationsState extends Equatable {
  const ReturnReceivingOperationsState({
    this.operationIds = const [],
    this.createdOperationId,
    this.isEmpty = false,
  });

  final List<String> operationIds;
  final String? createdOperationId;
  final bool isEmpty;

  ReturnReceivingOperationsState copyWith({
    List<String>? operationIds,
    String? createdOperationId,
    bool? isEmpty,
  }) =>
      ReturnReceivingOperationsState(
        operationIds: operationIds ?? this.operationIds,
        createdOperationId: createdOperationId ?? this.createdOperationId,
        isEmpty: isEmpty ?? this.isEmpty,
      );

  @override
  List<Object?> get props => [operationIds, createdOperationId, isEmpty];
}
