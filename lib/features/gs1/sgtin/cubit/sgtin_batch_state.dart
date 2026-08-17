import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';

class SgtinBatchState extends Equatable {
  final SgtinBatchLookupStatus status;
  final GtinBatch? resolvedBatch;
  final String? error;
  final int? gtinId;
  final String? lookupGtinCode;
  final String? lookupBatchLot;
  final bool registrationPanelExpanded;
  final int? registrationQuantityManufactured;

  const SgtinBatchState({
    this.status = SgtinBatchLookupStatus.idle,
    this.resolvedBatch,
    this.error,
    this.gtinId,
    this.lookupGtinCode,
    this.lookupBatchLot,
    this.registrationPanelExpanded = false,
    this.registrationQuantityManufactured,
  });

  bool get isBusy => status.isBusy;

  bool get canSubmitSgtin => status.canSubmitSgtin;

  SgtinBatchState copyWith({
    SgtinBatchLookupStatus? status,
    GtinBatch? resolvedBatch,
    bool clearResolvedBatch = false,
    String? error,
    bool clearError = false,
    int? gtinId,
    bool clearGtinId = false,
    String? lookupGtinCode,
    bool clearLookupGtinCode = false,
    String? lookupBatchLot,
    bool clearLookupBatchLot = false,
    bool? registrationPanelExpanded,
    int? registrationQuantityManufactured,
    bool clearRegistrationQuantityManufactured = false,
    bool clearAll = false,
  }) {
    if (clearAll) {
      return const SgtinBatchState();
    }

    return SgtinBatchState(
      status: status ?? this.status,
      resolvedBatch: clearResolvedBatch
          ? null
          : (resolvedBatch ?? this.resolvedBatch),
      error: clearError ? null : (error ?? this.error),
      gtinId: clearGtinId ? null : (gtinId ?? this.gtinId),
      lookupGtinCode: clearLookupGtinCode
          ? null
          : (lookupGtinCode ?? this.lookupGtinCode),
      lookupBatchLot: clearLookupBatchLot
          ? null
          : (lookupBatchLot ?? this.lookupBatchLot),
      registrationPanelExpanded:
          registrationPanelExpanded ?? this.registrationPanelExpanded,
      registrationQuantityManufactured: clearRegistrationQuantityManufactured
          ? null
          : (registrationQuantityManufactured ??
                this.registrationQuantityManufactured),
    );
  }

  @override
  List<Object?> get props => [
    status,
    resolvedBatch,
    error,
    gtinId,
    lookupGtinCode,
    lookupBatchLot,
    registrationPanelExpanded,
    registrationQuantityManufactured,
  ];
}
