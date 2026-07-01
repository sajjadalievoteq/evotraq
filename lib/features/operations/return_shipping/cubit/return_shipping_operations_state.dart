part of 'return_shipping_operations_cubit.dart';

class ReturnShippingOperationsState extends Equatable {
  const ReturnShippingOperationsState({
    this.operationIds = const [],
    this.createdOperationId,
    this.isEmpty = false,
  });

  final List<String> operationIds;
  final String? createdOperationId;
  final bool isEmpty;

  ReturnShippingOperationsState copyWith({
    List<String>? operationIds,
    String? createdOperationId,
    bool? isEmpty,
  }) =>
      ReturnShippingOperationsState(
        operationIds: operationIds ?? this.operationIds,
        createdOperationId: createdOperationId ?? this.createdOperationId,
        isEmpty: isEmpty ?? this.isEmpty,
      );

  @override
  List<Object?> get props => [operationIds, createdOperationId, isEmpty];
}
