part of 'decommissioning_operations_cubit.dart';

class DecommissioningOperationsState extends Equatable {
  const DecommissioningOperationsState({
    this.operationIds = const [],
    this.createdOperationId,
    this.isEmpty = false,
  });

  final List<String> operationIds;
  final String? createdOperationId;
  final bool isEmpty;

  DecommissioningOperationsState copyWith({
    List<String>? operationIds,
    String? createdOperationId,
    bool? isEmpty,
  }) =>
      DecommissioningOperationsState(
        operationIds: operationIds ?? this.operationIds,
        createdOperationId: createdOperationId ?? this.createdOperationId,
        isEmpty: isEmpty ?? this.isEmpty,
      );

  @override
  List<Object?> get props => [operationIds, createdOperationId, isEmpty];
}
