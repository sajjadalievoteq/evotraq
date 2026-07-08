import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';

class CommissioningOperationState extends Equatable {
  final CommissioningResponse? lastResult;
  final bool loading;
  final String? error;

  final CommissioningBatchLookupStatus batchLookupStatus;
  final GtinBatch? resolvedBatch;
  final String? batchLookupError;
  final int? gtinDbId;
  final String? lookupGtinCode;
  final String? lookupBatchLot;
  final bool registrationPanelExpanded;
  final DateTime? registrationExpiryDate;
  final DateTime? registrationManufactureDate;
  final int? registrationQuantityManufactured;

  const CommissioningOperationState({
    this.lastResult,
    this.loading = false,
    this.error,
    this.batchLookupStatus = CommissioningBatchLookupStatus.idle,
    this.resolvedBatch,
    this.batchLookupError,
    this.gtinDbId,
    this.lookupGtinCode,
    this.lookupBatchLot,
    this.registrationPanelExpanded = false,
    this.registrationExpiryDate,
    this.registrationManufactureDate,
    this.registrationQuantityManufactured,
  });

  bool get isBatchBusy => batchLookupStatus.isBusy;

  bool get requiresBatchRegistration =>
      batchLookupStatus == CommissioningBatchLookupStatus.notFound;

  CommissioningOperationState copyWith({
    CommissioningResponse? lastResult,
    bool? loading,
    String? error,
    bool clearError = false,
    CommissioningBatchLookupStatus? batchLookupStatus,
    GtinBatch? resolvedBatch,
    bool clearResolvedBatch = false,
    String? batchLookupError,
    bool clearBatchLookupError = false,
    int? gtinDbId,
    bool clearGtinDbId = false,
    String? lookupGtinCode,
    bool clearLookupGtinCode = false,
    String? lookupBatchLot,
    bool clearLookupBatchLot = false,
    bool? registrationPanelExpanded,
    DateTime? registrationExpiryDate,
    bool clearRegistrationExpiryDate = false,
    DateTime? registrationManufactureDate,
    bool clearRegistrationManufactureDate = false,
    int? registrationQuantityManufactured,
    bool clearRegistrationQuantityManufactured = false,
    bool clearBatchState = false,
  }) {
    if (clearBatchState) {
      return CommissioningOperationState(
        lastResult: lastResult ?? this.lastResult,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );
    }

    return CommissioningOperationState(
      lastResult: lastResult ?? this.lastResult,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      batchLookupStatus: batchLookupStatus ?? this.batchLookupStatus,
      resolvedBatch:
          clearResolvedBatch ? null : (resolvedBatch ?? this.resolvedBatch),
      batchLookupError: clearBatchLookupError
          ? null
          : (batchLookupError ?? this.batchLookupError),
      gtinDbId: clearGtinDbId ? null : (gtinDbId ?? this.gtinDbId),
      lookupGtinCode: clearLookupGtinCode
          ? null
          : (lookupGtinCode ?? this.lookupGtinCode),
      lookupBatchLot: clearLookupBatchLot
          ? null
          : (lookupBatchLot ?? this.lookupBatchLot),
      registrationPanelExpanded:
          registrationPanelExpanded ?? this.registrationPanelExpanded,
      registrationExpiryDate: clearRegistrationExpiryDate
          ? null
          : (registrationExpiryDate ?? this.registrationExpiryDate),
      registrationManufactureDate: clearRegistrationManufactureDate
          ? null
          : (registrationManufactureDate ?? this.registrationManufactureDate),
      registrationQuantityManufactured: clearRegistrationQuantityManufactured
          ? null
          : (registrationQuantityManufactured ??
              this.registrationQuantityManufactured),
    );
  }

  @override
  List<Object?> get props => [
        lastResult,
        loading,
        error,
        batchLookupStatus,
        resolvedBatch,
        batchLookupError,
        gtinDbId,
        lookupGtinCode,
        lookupBatchLot,
        registrationPanelExpanded,
        registrationExpiryDate,
        registrationManufactureDate,
        registrationQuantityManufactured,
      ];
}
