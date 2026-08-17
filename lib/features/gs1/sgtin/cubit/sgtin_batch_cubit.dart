import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/pharma_service.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

class SgtinBatchCubit extends Cubit<SgtinBatchState> {
  SgtinBatchCubit({required PharmaService pharmaService})
    : _pharmaService = pharmaService,
      super(const SgtinBatchState());

  final PharmaService _pharmaService;

  Timer? _lookupDebounce;
  static const _lookupDebounceDuration = Duration(milliseconds: 400);
  int _lookupGeneration = 0;

  @override
  Future<void> close() {
    _cancelDebounce();
    return super.close();
  }

  void _cancelDebounce() {
    _lookupDebounce?.cancel();
    _lookupDebounce = null;
  }

  void clear() {
    _cancelDebounce();
    _lookupGeneration++;
    emit(const SgtinBatchState());
  }

  void onGtinChanged({int? gtinId, String? gtinCode}) {
    _cancelDebounce();
    _lookupGeneration++;
    emit(SgtinBatchState(gtinId: gtinId, lookupGtinCode: gtinCode));
  }

  void onBatchLotInputChanged(String batchLot) {
    final gtinId = state.gtinId;
    final gtinCode = state.lookupGtinCode;
    final trimmed = batchLot.trim();
    if (gtinId == null || gtinCode == null || gtinCode.isEmpty) {
      _cancelDebounce();
      _lookupGeneration++;
      emit(
        state.copyWith(
          status: SgtinBatchLookupStatus.idle,
          clearResolvedBatch: true,
          clearError: true,
          lookupBatchLot: trimmed.isEmpty ? null : trimmed,
          clearLookupBatchLot: trimmed.isEmpty,
          registrationPanelExpanded: false,
        ),
      );
      return;
    }
    if (trimmed.isEmpty) {
      _cancelDebounce();
      _lookupGeneration++;
      emit(
        state.copyWith(
          status: SgtinBatchLookupStatus.idle,
          clearResolvedBatch: true,
          clearError: true,
          clearLookupBatchLot: true,
          registrationPanelExpanded: false,
        ),
      );
      return;
    }

    if (sgtin_validators.validateBatchLotNumber(trimmed) != null) {
      _cancelDebounce();
      _lookupGeneration++;
      emit(
        state.copyWith(
          status: SgtinBatchLookupStatus.idle,
          clearResolvedBatch: true,
          lookupBatchLot: trimmed,
          registrationPanelExpanded: false,
        ),
      );
      return;
    }

    if (!_needsLookup(gtinCode, trimmed)) {
      return;
    }

    _cancelDebounce();
    emit(
      state.copyWith(
        status: SgtinBatchLookupStatus.lookingUp,
        clearError: true,
        lookupBatchLot: trimmed,
        registrationPanelExpanded: false,
      ),
    );
    _lookupDebounce = Timer(_lookupDebounceDuration, () {
      unawaited(
        lookupBatch(gtinId: gtinId, gtinCode: gtinCode, batchLot: trimmed),
      );
    });
  }

  void triggerLookupNow(String batchLot) {
    _cancelDebounce();
    final gtinId = state.gtinId;
    final gtinCode = state.lookupGtinCode;
    final trimmed = batchLot.trim();
    if (gtinId == null || gtinCode == null || trimmed.isEmpty) return;
    if (sgtin_validators.validateBatchLotNumber(trimmed) != null) return;
    if (!_needsLookup(gtinCode, trimmed)) return;
    unawaited(
      lookupBatch(gtinId: gtinId, gtinCode: gtinCode, batchLot: trimmed),
    );
  }

  Future<void> lookupBatch({
    required int gtinId,
    required String gtinCode,
    required String batchLot,
  }) async {
    final generation = ++_lookupGeneration;
    final normalizedLot = batchLot.trim();
    final isNewTarget =
        state.lookupGtinCode != gtinCode ||
        state.lookupBatchLot != normalizedLot;
    emit(
      state.copyWith(
        status: SgtinBatchLookupStatus.lookingUp,
        clearError: true,
        clearResolvedBatch: true,
        gtinId: gtinId,
        lookupGtinCode: gtinCode,
        lookupBatchLot: normalizedLot,
        registrationPanelExpanded: isNewTarget
            ? false
            : state.registrationPanelExpanded,
      ),
    );

    try {
      final batch = await _pharmaService.tryGetBatchByLot(
        gtinId,
        normalizedLot,
      );
      if (isClosed || generation != _lookupGeneration) return;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return;

      if (batch != null) {
        emit(
          state.copyWith(
            status: SgtinBatchLookupStatus.found,
            resolvedBatch: batch,
            registrationPanelExpanded: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: SgtinBatchLookupStatus.notFound,
          registrationPanelExpanded: true,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed || generation != _lookupGeneration) return;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return;
      emit(
        state.copyWith(
          status: SgtinBatchLookupStatus.error,
          error: e.getUserFriendlyMessage(),
        ),
      );
    } catch (e) {
      if (isClosed || generation != _lookupGeneration) return;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return;
      emit(
        state.copyWith(
          status: SgtinBatchLookupStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  void setRegistrationPanelExpanded(bool expanded) {
    emit(state.copyWith(registrationPanelExpanded: expanded));
  }

  Future<bool> registerBatch({
    required String batchLot,
    DateTime? manufactureDate,
    DateTime? expiryDate,
    int? quantityManufactured,
  }) async {
    if (state.status == SgtinBatchLookupStatus.registering) {
      return false;
    }

    final gtinId = state.gtinId;
    final gtinCode = state.lookupGtinCode;
    final normalizedLot = batchLot.trim();
    if (gtinId == null || gtinCode == null || normalizedLot.isEmpty) {
      emit(
        state.copyWith(
          error:
              'Select a GTIN and enter a batch/lot number before registering.',
        ),
      );
      return false;
    }

    final lotError = sgtin_validators.validateBatchLotNumber(normalizedLot);
    if (lotError != null) {
      emit(state.copyWith(error: lotError));
      return false;
    }

    final manufacture = manufactureDate;
    final expiry = expiryDate;
    if (manufacture == null || expiry == null) {
      emit(
        state.copyWith(
          error:
              'Manufacture and expiry dates are required to register a batch.',
        ),
      );
      return false;
    }
    if (expiry.isBefore(manufacture)) {
      emit(
        state.copyWith(
          error: 'Expiry date must not be before manufacture date.',
        ),
      );
      return false;
    }

    final generation = ++_lookupGeneration;
    emit(
      state.copyWith(
        status: SgtinBatchLookupStatus.registering,
        clearError: true,
        lookupGtinCode: gtinCode,
        lookupBatchLot: normalizedLot,
      ),
    );

    final payload = GtinBatch(
      gtinId: gtinId,
      gtinCode: gtinCode,
      batchLotNumber: normalizedLot,
      expiryDate: _formatIsoDate(expiry),
      manufactureDate: _formatIsoDate(manufacture),
      quantityManufactured: quantityManufactured,
      recallAffected: false,
      batchStatus: 'ACTIVE',
    );

    try {
      final created = await _pharmaService.createBatch(gtinId, payload);
      if (isClosed || generation != _lookupGeneration) return false;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return false;

      emit(
        state.copyWith(
          status: SgtinBatchLookupStatus.registered,
          resolvedBatch: created,
          registrationPanelExpanded: false,
        ),
      );
      return true;
    } on ApiException catch (e) {
      if (isClosed || generation != _lookupGeneration) return false;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return false;

      if (e.statusCode == 409) {
        await lookupBatch(
          gtinId: gtinId,
          gtinCode: gtinCode,
          batchLot: normalizedLot,
        );
        return state.status.isResolved;
      }

      emit(
        state.copyWith(
          status: SgtinBatchLookupStatus.notFound,
          error: OperationApiErrorMessage.fromApiException(e),
          registrationPanelExpanded: true,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed || generation != _lookupGeneration) return false;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return false;
      emit(
        state.copyWith(
          status: SgtinBatchLookupStatus.notFound,
          error: e.toString(),
          registrationPanelExpanded: true,
        ),
      );
      return false;
    }
  }

  bool _matchesLookupContext(String gtinCode, String batchLot) {
    return state.lookupGtinCode == gtinCode && state.lookupBatchLot == batchLot;
  }

  bool _needsLookup(String gtinCode, String batchLot) {
    final normalizedLot = batchLot.trim();
    if (normalizedLot.isEmpty) return false;

    final sameTarget =
        state.lookupGtinCode == gtinCode &&
        state.lookupBatchLot == normalizedLot;
    if (!sameTarget) return true;

    return switch (state.status) {
      SgtinBatchLookupStatus.idle || SgtinBatchLookupStatus.error => true,
      SgtinBatchLookupStatus.lookingUp ||
      SgtinBatchLookupStatus.registering ||
      SgtinBatchLookupStatus.found ||
      SgtinBatchLookupStatus.notFound ||
      SgtinBatchLookupStatus.registered => false,
    };
  }

  static String _formatIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
