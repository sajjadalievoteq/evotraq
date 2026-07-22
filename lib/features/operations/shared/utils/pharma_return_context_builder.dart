import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
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

    final checks = await Future.wait([
      _hasReturnShippingInTransit(epcs),
      _resolveProduct(epcs),
    ]);
    final alreadyReturnShipped = checks[0] as bool;
    if (alreadyReturnShipped) return null;

    final product = checks[1] as _ProductSnapshot;
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
    String resolvedSourceEventId = eventId;

    final epcEvents = await _findEventsForEpcs(epcs);
    final alreadyReceived = epcEvents.any(
      (e) => PharmaReturnEligibility.isReturnAlreadyReceived(
        businessStep: e.businessStep,
        disposition: e.disposition,
      ),
    );
    if (alreadyReceived) return null;

    if (resolvedReason == null) {
      final inTransitEvent = epcEvents.where((event) {
        return PharmaReturnEligibility.isReturnShippingInTransit(
          businessStep: event.businessStep,
          disposition: event.disposition,
        );
      }).firstOrNull;
      if (inTransitEvent == null) return null;
      resolvedReturnShippingEventId = inTransitEvent.eventId;
      final ilmd = inTransitEvent.ilmd ?? const {};
      final sourceFromIlmd = ilmd[_ilmdSourceEventId]?.toString();
      if (sourceFromIlmd != null && sourceFromIlmd.trim().isNotEmpty) {
        resolvedSourceEventId = sourceFromIlmd.trim();
      }
      resolvedReason = PharmaReturnReason.fromCode(
        ilmd[_ilmdReturnReason]?.toString(),
      );
      if (resolvedReason == null) return null;
    } else if (operation.isReturnShipping) {
      resolvedReturnShippingEventId ??= eventId;
    }

    final product = await _resolveProduct(epcs);
    return PharmaReturnContext(
      sourceEventId: resolvedSourceEventId,
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

  static const _epcBatchSize = 50;

  Future<List<ObjectEvent>> _findEventsForEpcs(List<String> epcs) async {
    if (epcs.isEmpty) return const [];
    final all = <ObjectEvent>[];
    for (var i = 0; i < epcs.length; i += _epcBatchSize) {
      final end = i + _epcBatchSize;
      final chunk = epcs.sublist(i, end > epcs.length ? epcs.length : end);
      try {
        all.addAll(await _objectEventService.findObjectEventsByEPCs(chunk));
      } catch (_) {
        for (final epc in chunk) {
          try {
            all.addAll(await _objectEventService.findObjectEventsByEPC(epc));
          } catch (_) {}
        }
      }
    }
    return all;
  }

  Future<bool> _hasReturnShippingInTransit(List<String> epcs) async {
    final events = await _findEventsForEpcs(epcs);
    return events.any(
      (e) => PharmaReturnEligibility.isReturnShippingInTransit(
        businessStep: e.businessStep,
        disposition: e.disposition,
      ),
    );
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
      final gtinFromUri = _gtinFromEpc(epc);

      if (serial != null) {
        try {
          final sgtinFuture = _sgtinService.getSGTINBySerialNumber(serial);
          final descriptionFuture = gtinFromUri != null
              ? _productDescriptionForGtin(gtinFromUri)
              : Future<String?>.value(null);
          final results = await Future.wait<Object?>([
            sgtinFuture,
            descriptionFuture,
          ]);
          final sgtin = results[0] as SGTIN;
          var description = results[1] as String?;
          description ??= await _productDescriptionForGtin(sgtin.gtinCode);
          return _ProductSnapshot(
            gtin: sgtin.gtinCode,
            lotNumber: sgtin.batchLotNumber,
            expiryDate: sgtin.expiryDate ?? sgtin.expiryDateTime,
            productDescription: description,
          );
        } catch (_) {
          if (gtinFromUri != null) {
            final description = await _productDescriptionForGtin(gtinFromUri);
            return _ProductSnapshot(
              gtin: gtinFromUri,
              productDescription: description,
            );
          }
          continue;
        }
      }

      if (gtinFromUri != null) {
        final description = await _productDescriptionForGtin(gtinFromUri);
        return _ProductSnapshot(
          gtin: gtinFromUri,
          productDescription: description,
        );
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
    return Gs1CanonicalIdentifier.extractSerial(epc);
  }

  String? _gtinFromEpc(String epc) {
    return Gs1CanonicalIdentifier.extractGtin(epc);
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
