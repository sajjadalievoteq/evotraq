import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/services/epcis/object_event_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/features/operations/shared/models/pharma_return_context.dart';
import 'package:traqtrace_app/features/operations/shared/models/pharma_return_reason.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';
import 'package:traqtrace_app/features/operations/shared/utils/pharma_return_eligibility.dart';

/// Builds [PharmaReturnContext] from shipping / receiving operations.
class PharmaReturnContextBuilder {
  PharmaReturnContextBuilder({
    ObjectEventService? objectEventService,
    GLNService? glnService,
    SGTINService? sgtinService,
    GTINService? gtinService,
  })  : _objectEventService = objectEventService ?? getIt<ObjectEventService>(),
        _glnService = glnService ?? getIt<GLNService>(),
        _sgtinService = sgtinService ?? getIt<SGTINService>(),
        _gtinService = gtinService ?? getIt<GTINService>();

  final ObjectEventService _objectEventService;
  final GLNService _glnService;
  final SGTINService _sgtinService;
  final GTINService _gtinService;

  static const _ilmdSourceEventId = 'sourceEventID';
  static const _ilmdReturnReason = 'returnReason';

  Future<PharmaReturnContext?> fromReceiving(ReceivingResponse operation) async {
    final epcs = operation.epcList ?? const [];
    final eventId = operation.eventIds?.isNotEmpty == true
        ? operation.eventIds!.first
        : null;
    if (eventId == null || epcs.isEmpty) return null;

    if (!operation.isAccepted) {
      final accepted = await _hasAcceptingInStockEvent(eventId);
      if (!accepted) return null;
    }

    // Hide the button if a return shipping is already in transit — the return
    // has already been initiated and should not be duplicated.
    final alreadyReturnShipped = await _hasReturnShippingInTransit(epcs);
    if (alreadyReturnShipped) return null;

    final product = await _resolveProduct(epcs);
    final senderGln =
        PharmaReturnEligibility.normalizeGln(operation.sourceGLN) ?? '';
    final receiverGln =
        PharmaReturnEligibility.normalizeGln(operation.receivingGLN) ?? '';
    return PharmaReturnContext(
      sourceEventId: eventId,
      epcs: List<String>.from(epcs),
      senderGln: senderGln,
      receiverGln: receiverGln,
      gtin: product.gtin,
      lotNumber: product.lotNumber,
      expiryDate: product.expiryDate,
      quantity: operation.processedEpcsCount ?? epcs.length,
      productDescription: product.productDescription,
    );
  }

  Future<PharmaReturnContext?> fromShipping(
    ShippingResponse operation, {
    PharmaReturnReason? returnReason,
    String? returnShippingEventId,
  }) async {
    final epcs = operation.epcList ?? const [];
    final eventId = operation.eventIds?.isNotEmpty == true
        ? operation.eventIds!.first
        : null;
    if (eventId == null || epcs.isEmpty) return null;

    PharmaReturnReason? resolvedReason = returnReason;
    String? resolvedReturnShippingEventId = returnShippingEventId;

    if (resolvedReason == null) {
      // The ReturnShipping event's ILMD stores sourceEventID = receivingEventId
      // (not the shipping event ID), so we cannot search by ILMD from here.
      // Instead, find all events that carry any of the shipping EPCs and filter
      // for returning+in_transit — EPCs carry over exactly through the chain.
      ObjectEvent? inTransitEvent;
      for (final epc in epcs) {
        try {
          final epcEvents =
              await _objectEventService.findObjectEventsByEPC(epc);
          inTransitEvent = epcEvents.where((event) {
            return PharmaReturnEligibility.isReturnShippingInTransit(
              businessStep: event.businessStep,
              disposition: event.disposition,
            );
          }).firstOrNull;
          if (inTransitEvent != null) break;
        } catch (_) {
          continue;
        }
      }
      if (inTransitEvent == null) return null;
      resolvedReturnShippingEventId = inTransitEvent.eventId;
      final ilmd = inTransitEvent.ilmd ?? const {};
      resolvedReason = PharmaReturnReason.fromCode(
        ilmd[_ilmdReturnReason]?.toString(),
      );
      if (resolvedReason == null) return null;
    }

    // Hide the button if the return has already been received — the full return
    // cycle (ReturnShipping → ReturnReceiving) is complete.
    final alreadyReceived = await _hasReturnAlreadyReceived(epcs);
    if (alreadyReceived) return null;

    final product = await _resolveProduct(epcs);
    return PharmaReturnContext(
      sourceEventId: eventId,
      epcs: List<String>.from(epcs),
      senderGln: operation.sourceGLN ?? '',
      receiverGln: operation.destinationGLN ?? '',
      gtin: product.gtin,
      lotNumber: product.lotNumber,
      expiryDate: product.expiryDate,
      quantity: operation.shippedEpcsCount ?? epcs.length,
      productDescription: product.productDescription,
      returnReason: resolvedReason,
      returnShippingEventId: resolvedReturnShippingEventId,
    );
  }

  Future<GLN?> loadGln(String? code) async {
    if (code == null || code.trim().isEmpty) return null;
    try {
      return await _glnService.getGLNByCode(code.trim());
    } catch (_) {
      return null;
    }
  }


  Future<bool> _hasAcceptingInStockEvent(String receivingEventId) async {
    try {
      final events = await _objectEventService.findObjectEventsByILMD(
        _ilmdSourceEventId,
        receivingEventId,
      );
      return events.any(
        (event) => PharmaReturnEligibility.isAcceptingInStock(
          businessStep: event.businessStep,
          disposition: event.disposition,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Returns true when any of [epcs] already has a returning+in_transit event,
  /// meaning the return shipping cycle has already been initiated.
  Future<bool> _hasReturnShippingInTransit(List<String> epcs) async {
    for (final epc in epcs) {
      try {
        final events = await _objectEventService.findObjectEventsByEPC(epc);
        final found = events.any(
          (e) => PharmaReturnEligibility.isReturnShippingInTransit(
            businessStep: e.businessStep,
            disposition: e.disposition,
          ),
        );
        if (found) return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  /// Returns true when any of [epcs] already has an accepting+returned/recalled/
  /// damaged event, meaning the full return cycle is complete.
  Future<bool> _hasReturnAlreadyReceived(List<String> epcs) async {
    for (final epc in epcs) {
      try {
        final events = await _objectEventService.findObjectEventsByEPC(epc);
        final found = events.any(
          (e) => PharmaReturnEligibility.isReturnAlreadyReceived(
            businessStep: e.businessStep,
            disposition: e.disposition,
          ),
        );
        if (found) return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  Future<bool> hasAcceptingEventForReceiving(ReceivingResponse operation) async {
    final eventId = operation.eventIds?.isNotEmpty == true
        ? operation.eventIds!.first
        : null;
    if (eventId == null) return false;
    return _hasAcceptingInStockEvent(eventId);
  }

  Future<_ProductSnapshot> _resolveProduct(List<String> epcs) async {
    for (final epc in epcs) {
      if (OperationEpcScanValidator.resolveEpcType(epc) !=
          OperationScanItemType.sgtin) {
        continue;
      }
      final serial = _serialFromEpc(epc);
      if (serial == null) continue;
      try {
        final sgtin = await _sgtinService.getSGTINBySerialNumber(serial);
        final description = await _productDescriptionForGtin(sgtin.gtinCode);
        return _ProductSnapshot(
          gtin: sgtin.gtinCode,
          lotNumber: sgtin.batchLotNumber,
          expiryDate: sgtin.expiryDate ?? sgtin.expiryDateTime,
          productDescription: description,
        );
      } catch (_) {
        continue;
      }
    }
    return const _ProductSnapshot();
  }

  Future<String?> _productDescriptionForGtin(String gtinCode) async {
    try {
      final GTIN gtin = await _gtinService.getGTIN(gtinCode);
      if (gtin.tradeItemDescription?.trim().isNotEmpty == true) {
        return gtin.tradeItemDescription;
      }
      if (gtin.productName.trim().isNotEmpty) return gtin.productName;
    } catch (_) {}
    return null;
  }

  String? _serialFromEpc(String epc) {
    if (epc.startsWith('urn:epc:id:sgtin:')) {
      final parts = epc.substring('urn:epc:id:sgtin:'.length).split('.');
      if (parts.length == 3) return parts[2];
    }
    return null;
  }
}

class _ProductSnapshot {
  const _ProductSnapshot({
    this.gtin,
    this.lotNumber,
    this.expiryDate,
    this.productDescription,
  });

  final String? gtin;
  final String? lotNumber;
  final DateTime? expiryDate;
  final String? productDescription;
}
