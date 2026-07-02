part of 'cancel_receiving_operations_cubit.dart';

class CancelReceivingOperationsState extends Equatable {
  const CancelReceivingOperationsState({
    this.operationIds = const [],
    this.createdOperationId,
    this.isEmpty = false,
  });

  final List<String> operationIds;
  final String? createdOperationId;
  final bool isEmpty;

  CancelReceivingOperationsState copyWith({
    List<String>? operationIds,
    String? createdOperationId,
    bool? isEmpty,
  }) =>
      CancelReceivingOperationsState(
        operationIds: operationIds ?? this.operationIds,
        createdOperationId: createdOperationId ?? this.createdOperationId,
        isEmpty: isEmpty ?? this.isEmpty,
      );

  @override
  List<Object?> get props => [operationIds, createdOperationId, isEmpty];
}
