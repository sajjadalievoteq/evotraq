part of 'receiving_acceptance_cubit.dart';

enum ReceivingAcceptanceStatus { idle, loading, success, error }

class ReceivingAcceptanceState extends Equatable {
  const ReceivingAcceptanceState({
    this.status = ReceivingAcceptanceStatus.idle,
    this.updatedOperation,
    this.errorMessage,
  });

  final ReceivingAcceptanceStatus status;
  final ReceivingResponse? updatedOperation;
  final String? errorMessage;

  ReceivingAcceptanceState copyWith({
    ReceivingAcceptanceStatus? status,
    ReceivingResponse? updatedOperation,
    String? errorMessage,
    bool clearUpdatedOperation = false,
    bool clearError = false,
  }) {
    return ReceivingAcceptanceState(
      status: status ?? this.status,
      updatedOperation:
          clearUpdatedOperation ? null : (updatedOperation ?? this.updatedOperation),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, updatedOperation, errorMessage];
}
