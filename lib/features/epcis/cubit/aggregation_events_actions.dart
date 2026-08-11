part of 'aggregation_events_cubit.dart';

extension AggregationEventsActions on AggregationEventsCubit {
  Future<AggregationEvent> createAggregationEvent(
    AggregationEvent event,
  ) async {
    emit(
      state.copyWith(status: AggregationEventsStatus.loading, clearError: true),
    );
    try {
      final newEvent = await _service.createAggregationEvent(event);
      emit(
        state.copyWith(
          status: AggregationEventsStatus.success,
          selectedEvent: newEvent,
          aggregationEvents: [newEvent, ...state.aggregationEvents],
        ),
      );
      return newEvent;
    } catch (e) {
      emit(
        state.copyWith(
          status: AggregationEventsStatus.error,
          error: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Pack via `/operations/packing` (validated projection path), not raw aggregation POST.
  Future<AggregationEvent> createPackEvent({
    required String parentEPC,
    required List<String> childEPCs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    List<Map<String, dynamic>>? sourceList,
    List<Map<String, dynamic>>? destinationList,
  }) async {
    emit(
      state.copyWith(status: AggregationEventsStatus.loading, clearError: true),
    );
    try {
      final ref = bizData['traqtrace:packingReference']?.trim();
      final result = await _packingService.createPackingOperation(
        PackingRequest(
          packingReference: (ref != null && ref.isNotEmpty)
              ? ref
              : 'AGG-FORM-${DateTime.now().millisecondsSinceEpoch}',
          parentContainerId: parentEPC,
          childEpcs: childEPCs,
          packingLocationGLN: locationGLN,
          readPointGLN: locationGLN,
          workOrderNumber: bizData['traqtrace:workOrderNumber'],
          batchNumber: bizData['traqtrace:batchNumber'],
          productionOrder: bizData['traqtrace:productionOrder'],
          additionalData: bizData.isEmpty
              ? null
              : Map<String, String>.from(bizData),
        ),
      );
      if (result.hasErrors) {
        throw Exception(
          (result.messages ?? const <String>[]).join('\n').trim().isEmpty
              ? 'Packing operation failed'
              : result.messages!.join('\n'),
        );
      }

      final newEvent = await _resolveCreatedAggregationEvent(
        preferredEventId:
            result.eventIds?.where((e) => e.trim().isNotEmpty).firstOrNull ??
            result.navigableOperationId,
        parentEPC: parentEPC,
        childEPCs: childEPCs,
        locationGLN: locationGLN,
        businessStep: businessStep,
        disposition: disposition,
        action: 'ADD',
        bizData: bizData,
      );
      emit(
        state.copyWith(
          status: AggregationEventsStatus.success,
          selectedEvent: newEvent,
          aggregationEvents: [newEvent, ...state.aggregationEvents],
        ),
      );
      return newEvent;
    } catch (e) {
      emit(
        state.copyWith(
          status: AggregationEventsStatus.error,
          error: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Unpack via `/operations/unpacking` (validated projection path), not raw aggregation POST.
  Future<AggregationEvent> createUnpackEvent({
    required String parentEPC,
    List<String>? childEPCs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    List<Map<String, dynamic>>? sourceList,
    List<Map<String, dynamic>>? destinationList,
  }) async {
    emit(
      state.copyWith(status: AggregationEventsStatus.loading, clearError: true),
    );
    try {
      final children = childEPCs ?? const <String>[];
      final ref = bizData['traqtrace:unpackingReference']?.trim();
      final result = await _unpackingService.createUnpackingOperation(
        UnpackingRequest(
          unpackingReference: (ref != null && ref.isNotEmpty)
              ? ref
              : 'AGG-FORM-${DateTime.now().millisecondsSinceEpoch}',
          parentContainerId: parentEPC,
          childEpcs: children,
          unpackingLocationGLN: locationGLN,
          readPointGLN: locationGLN,
          workOrderNumber: bizData['traqtrace:workOrderNumber'],
          batchNumber: bizData['traqtrace:batchNumber'],
          productionOrder: bizData['traqtrace:productionOrder'],
          additionalData: bizData.isEmpty
              ? null
              : Map<String, String>.from(bizData),
        ),
      );
      if (result.hasErrors) {
        throw Exception(
          (result.messages ?? const <String>[]).join('\n').trim().isEmpty
              ? 'Unpacking operation failed'
              : result.messages!.join('\n'),
        );
      }

      final newEvent = await _resolveCreatedAggregationEvent(
        preferredEventId:
            result.eventIds?.where((e) => e.trim().isNotEmpty).firstOrNull ??
            result.navigableOperationId,
        parentEPC: parentEPC,
        childEPCs: children,
        locationGLN: locationGLN,
        businessStep: businessStep,
        disposition: disposition,
        action: 'DELETE',
        bizData: bizData,
      );
      emit(
        state.copyWith(
          status: AggregationEventsStatus.success,
          selectedEvent: newEvent,
          aggregationEvents: [newEvent, ...state.aggregationEvents],
        ),
      );
      return newEvent;
    } catch (e) {
      emit(
        state.copyWith(
          status: AggregationEventsStatus.error,
          error: e.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<AggregationEvent> _resolveCreatedAggregationEvent({
    required String? preferredEventId,
    required String parentEPC,
    required List<String> childEPCs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required String action,
    required Map<String, String> bizData,
  }) async {
    final id = preferredEventId?.trim();
    if (id != null && id.isNotEmpty) {
      try {
        return await _service.getAggregationEventByIdentifier(id);
      } catch (_) {
        // Fall through to a client-side stub for list UX.
      }
    }
    final now = DateTime.now();
    return AggregationEvent(
      eventId: id ?? 'pending-${now.millisecondsSinceEpoch}',
      eventTime: now,
      recordTime: now,
      eventTimeZone: '+00:00',
      action: action,
      parentID: parentEPC,
      childEPCs: childEPCs,
      businessStep: businessStep,
      disposition: disposition,
      readPoint: GLN.fromCode(locationGLN),
      businessLocation: GLN.fromCode(locationGLN),
      bizData: bizData.isEmpty ? null : Map<String, String>.from(bizData),
    );
  }

  Future<AggregationEvent?> findCurrentParentOfChild(String childEPC) async {
    try {
      return await _service.findCurrentParentOfChild(childEPC);
    } catch (_) {
      return null;
    }
  }

  Future<void> trackParentHistory(String parentEPC) async {
    emit(state.copyWith(isListLoading: true, clearListFetchError: true));
    try {
      final raw = await _service.findAggregationEventsByParentEPC(parentEPC);
      final events = await _enrichWithGlns(raw);
      emit(
        state.copyWith(
          status: AggregationEventsStatus.success,
          aggregationEvents: events,
          isListLoading: false,
          hasMoreData: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AggregationEventsStatus.error,
          isListLoading: false,
          listFetchError: e.toString(),
        ),
      );
    }
  }

  Future<void> trackChildHistory(String childEPC) async {
    emit(state.copyWith(isListLoading: true, clearListFetchError: true));
    try {
      final raw = await _service.findAggregationEventsByChildEPC(childEPC);
      final events = await _enrichWithGlns(raw);
      emit(
        state.copyWith(
          status: AggregationEventsStatus.success,
          aggregationEvents: events,
          isListLoading: false,
          hasMoreData: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AggregationEventsStatus.error,
          isListLoading: false,
          listFetchError: e.toString(),
        ),
      );
    }
  }

  Future<List<String>> loadContainerContents(String parentEPC) async {
    try {
      return await _service.findContainerContents(parentEPC);
    } catch (_) {
      return [];
    }
  }

  Future<bool> verifyHierarchy(String epc) async {
    try {
      return await _service.verifyHierarchy(epc);
    } catch (_) {
      return false;
    }
  }
}
