import 'package:equatable/equatable.dart';

class OperationDetailState<T> extends Equatable {
  const OperationDetailState({
    this.operation,
    this.isLoading = false,
    this.errorMessage,
  });

  final T? operation;
  final bool isLoading;
  final String? errorMessage;

  OperationDetailState<T> copyWith({
    T? operation,
    bool isLoading = false,
    String? errorMessage,
    bool clearOperation = false,
    bool clearErrorMessage = false,
  }) {
    return OperationDetailState<T>(
      operation: clearOperation ? null : (operation ?? this.operation),
      isLoading: isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [operation, isLoading, errorMessage];
}
