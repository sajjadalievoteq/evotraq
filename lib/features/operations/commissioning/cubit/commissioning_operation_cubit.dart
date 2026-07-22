import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/pharma_service.dart';
import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_state.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

class CommissioningOperationCubit extends Cubit<CommissioningOperationState> {
  CommissioningOperationCubit({
    required CommissioningOperationService commissioningService,
    required PharmaService pharmaService,
    required PharmaceuticalService pharmaceuticalService,
  })  : _service = commissioningService,
        _pharmaService = pharmaService,
        _pharmaceuticalService = pharmaceuticalService,
        super(const CommissioningOperationState());

  final CommissioningOperationService _service;
  final PharmaService _pharmaService;
  final PharmaceuticalService _pharmaceuticalService;

  Timer? _batchLookupDebounce;
  static const _batchLookupDebounceDuration = Duration(milliseconds: 400);

  int _lookupGeneration = 0;

  void clearError() => emit(state.copyWith(clearError: true));

  void reset() {
    _cancelBatchLookupDebounce();
    _lookupGeneration++;
    emit(const CommissioningOperationState());
  }

  @override
  Future<void> close() {
    _cancelBatchLookupDebounce();
    return super.close();
  }

  void _cancelBatchLookupDebounce() {
    _batchLookupDebounce?.cancel();
    _batchLookupDebounce = null;
  }

  void clearBatchState() {
    _cancelBatchLookupDebounce();
    _lookupGeneration++;
    emit(state.copyWith(clearBatchState: true));
  }

  
  
  Future<bool> onPharmaGtinIdentified(String gtinCode) async {
    _cancelBatchLookupDebounce();
    _lookupGeneration++;
    emit(
      state.copyWith(
        clearBatchState: true,
        batchLookupStatus: CommissioningBatchLookupStatus.idle,
      ),
    );

    final dbId = await _resolveGtinDbId(gtinCode);
    if (isClosed) return false;
    if (dbId == null) return false;

    emit(state.copyWith(gtinDbId: dbId));
    return true;
  }

  void onBatchLotInputChanged({
    required String? gtinCode,
    required bool isPharmaGtin,
    required String batchLot,
  }) {
    if (!isPharmaGtin || gtinCode == null) return;
    final trimmed = batchLot.trim();
    if (trimmed.isEmpty) {
      _cancelBatchLookupDebounce();
      _lookupGeneration++;
      emit(
        state.copyWith(
          batchLookupStatus: CommissioningBatchLookupStatus.idle,
          clearResolvedBatch: true,
          clearBatchLookupError: true,
          clearLookupBatchLot: true,
          registrationPanelExpanded: false,
        ),
      );
      return;
    }

    final dbId = state.gtinDbId;
    if (dbId == null) return;

    _cancelBatchLookupDebounce();
    _batchLookupDebounce = Timer(_batchLookupDebounceDuration, () {
      if (!_needsBatchLookup(gtinCode, trimmed)) return;
      unawaited(
        lookupBatch(
          gtinDbId: dbId,
          gtinCode: gtinCode,
          batchLot: trimmed,
        ),
      );
    });
  }

  void triggerBatchLookupNow({
    required String? gtinCode,
    required bool isPharmaGtin,
    required String batchLot,
  }) {
    _cancelBatchLookupDebounce();
    if (!isPharmaGtin || gtinCode == null) return;
    final trimmed = batchLot.trim();
    if (trimmed.isEmpty) return;
    final dbId = state.gtinDbId;
    if (dbId == null) return;
    if (!_needsBatchLookup(gtinCode, trimmed)) return;
    unawaited(
      lookupBatch(
        gtinDbId: dbId,
        gtinCode: gtinCode,
        batchLot: trimmed,
      ),
    );
  }

  Future<void> lookupBatch({
    required int gtinDbId,
    required String gtinCode,
    required String batchLot,
  }) async {
    final generation = ++_lookupGeneration;
    final normalizedLot = batchLot.trim();
    final isNewLookupTarget =
        state.lookupGtinCode != gtinCode || state.lookupBatchLot != normalizedLot;
    emit(
      state.copyWith(
        batchLookupStatus: CommissioningBatchLookupStatus.lookingUp,
        clearBatchLookupError: true,
        clearResolvedBatch: true,
        lookupGtinCode: gtinCode,
        lookupBatchLot: normalizedLot,
        registrationPanelExpanded:
            isNewLookupTarget ? false : state.registrationPanelExpanded,
        gtinDbId: gtinDbId,
      ),
    );

    try {
      final batch = await _pharmaService.tryGetBatchByLot(
        gtinDbId,
        normalizedLot,
      );
      if (isClosed || generation != _lookupGeneration) return;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return;

      if (batch != null) {
        emit(
          state.copyWith(
            batchLookupStatus: CommissioningBatchLookupStatus.found,
            resolvedBatch: batch,
            registrationPanelExpanded: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          batchLookupStatus: CommissioningBatchLookupStatus.notFound,
          registrationPanelExpanded: true,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed || generation != _lookupGeneration) return;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return;
      emit(
        state.copyWith(
          batchLookupStatus: CommissioningBatchLookupStatus.error,
          batchLookupError: e.getUserFriendlyMessage(),
        ),
      );
    } catch (e) {
      if (isClosed || generation != _lookupGeneration) return;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return;
      emit(
        state.copyWith(
          batchLookupStatus: CommissioningBatchLookupStatus.error,
          batchLookupError: e.toString(),
        ),
      );
    }
  }

  void setRegistrationPanelExpanded(bool expanded) {
    emit(state.copyWith(registrationPanelExpanded: expanded));
  }

  void setRegistrationExpiryDate(DateTime? value) {
    emit(
      state.copyWith(
        registrationExpiryDate: value,
        clearRegistrationExpiryDate: value == null,
      ),
    );
  }

  void setRegistrationManufactureDate(DateTime? value) {
    emit(
      state.copyWith(
        registrationManufactureDate: value,
        clearRegistrationManufactureDate: value == null,
      ),
    );
  }

  void setRegistrationQuantityManufactured(int? value) {
    emit(
      state.copyWith(
        registrationQuantityManufactured: value,
        clearRegistrationQuantityManufactured: value == null,
      ),
    );
  }

  Future<bool> registerBatch({
    required int gtinDbId,
    required String gtinCode,
    required String batchLot,
  }) async {
    final normalizedLot = batchLot.trim();
    final expiry = state.registrationExpiryDate;
    if (expiry == null) {
      emit(
        state.copyWith(
          batchLookupError: 'Expiry date is required to register a batch.',
        ),
      );
      return false;
    }

    final generation = ++_lookupGeneration;
    emit(
      state.copyWith(
        batchLookupStatus: CommissioningBatchLookupStatus.registering,
        clearBatchLookupError: true,
        lookupGtinCode: gtinCode,
        lookupBatchLot: normalizedLot,
        gtinDbId: gtinDbId,
      ),
    );

    final payload = GtinBatch(
      gtinId: gtinDbId,
      gtinCode: gtinCode,
      batchLotNumber: normalizedLot,
      expiryDate: _formatIsoDate(expiry),
      manufactureDate: state.registrationManufactureDate != null
          ? _formatIsoDate(state.registrationManufactureDate!)
          : null,
      quantityManufactured: state.registrationQuantityManufactured,
      recallAffected: false,
      batchStatus: 'ACTIVE',
    );

    try {
      final created = await _pharmaService.createBatch(gtinDbId, payload);
      if (isClosed || generation != _lookupGeneration) return false;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return false;

      emit(
        state.copyWith(
          batchLookupStatus: CommissioningBatchLookupStatus.registered,
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
          gtinDbId: gtinDbId,
          gtinCode: gtinCode,
          batchLot: normalizedLot,
        );
        return state.batchLookupStatus == CommissioningBatchLookupStatus.found ||
            state.batchLookupStatus == CommissioningBatchLookupStatus.registered;
      }

      final message = OperationApiErrorMessage.fromApiException(e);
      emit(
        state.copyWith(
          batchLookupStatus: CommissioningBatchLookupStatus.notFound,
          batchLookupError: message,
          registrationPanelExpanded: true,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed || generation != _lookupGeneration) return false;
      if (!_matchesLookupContext(gtinCode, normalizedLot)) return false;
      emit(
        state.copyWith(
          batchLookupStatus: CommissioningBatchLookupStatus.notFound,
          batchLookupError: e.toString(),
          registrationPanelExpanded: true,
        ),
      );
      return false;
    }
  }

  Future<CommissioningResponse?> commissionBulk(
    CommissioningRequest request,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final response = await _service.createCommissioningOperation(request);
      emit(state.copyWith(lastResult: response, loading: false, clearError: true));
      return response;
    } on ApiException {
      emit(state.copyWith(loading: false));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }

  Future<CommissioningResponse?> commissionSscc(
    SsccCommissioningRequest request,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final response = await _service.createSsccCommissioningOperation(request);
      emit(state.copyWith(lastResult: response, loading: false, clearError: true));
      return response;
    } on ApiException {
      emit(state.copyWith(loading: false));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }

  bool _matchesLookupContext(String gtinCode, String batchLot) {
    return state.lookupGtinCode == gtinCode && state.lookupBatchLot == batchLot;
  }

  bool _needsBatchLookup(String gtinCode, String batchLot) {
    final normalizedLot = batchLot.trim();
    if (normalizedLot.isEmpty) return false;

    final sameTarget = state.lookupGtinCode == gtinCode &&
        state.lookupBatchLot == normalizedLot;
    if (!sameTarget) return true;

    return switch (state.batchLookupStatus) {
      CommissioningBatchLookupStatus.idle ||
      CommissioningBatchLookupStatus.error =>
        true,
      CommissioningBatchLookupStatus.lookingUp ||
      CommissioningBatchLookupStatus.registering ||
      CommissioningBatchLookupStatus.found ||
      CommissioningBatchLookupStatus.notFound ||
      CommissioningBatchLookupStatus.registered =>
        false,
    };
  }

  Future<int?> _resolveGtinDbId(String gtinCode) async {
    try {
      final ext =
          await _pharmaceuticalService.getExtensionByGtinCode(gtinCode);
      if (ext != null && ext.gtinId > 0) return ext.gtinId;
    } catch (_) {}
    return null;
  }

  static String _formatIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
