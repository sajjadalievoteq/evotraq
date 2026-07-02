part of 'cancel_shipping_operations_cubit.dart';

class CancelShippingOperationsState extends Equatable {
  const CancelShippingOperationsState({
    this.operationIds = const [],
    this.createdOperationId,
    this.isEmpty = false,
  });

  final List<String> operationIds;
  final String? createdOperationId;
  final bool isEmpty;

  CancelShippingOperationsState copyWith({
    List<String>? operationIds,
    String? createdOperationId,
    bool? isEmpty,
  }) =>
      CancelShippingOperationsState(
        operationIds: operationIds ?? this.operationIds,
        createdOperationId: createdOperationId ?? this.createdOperationId,
        isEmpty: isEmpty ?? this.isEmpty,
      );

  @override
  List<Object?> get props => [operationIds, createdOperationId, isEmpty];
}
