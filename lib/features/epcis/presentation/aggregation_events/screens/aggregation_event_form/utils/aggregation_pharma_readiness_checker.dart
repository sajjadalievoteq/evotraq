import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_input_parser.dart';

class AggregationPharmaReadinessChecker {
  AggregationPharmaReadinessChecker({
    required GLNService glnService,
    required SGTINService sgtinService,
    required SSCCService ssccService,
  })  : _glnService = glnService,
        _sgtinService = sgtinService,
        _ssccService = ssccService;

  final GLNService _glnService;
  final SGTINService _sgtinService;
  final SSCCService _ssccService;

  static const _packableSscc = {
    LogisticUnitStatus.ALLOCATED,
    LogisticUnitStatus.ACTIVE,
    LogisticUnitStatus.RECEIVED,
  };

  static const _packableSgtin = {
    ItemStatus.COMMISSIONED,
    ItemStatus.ACTIVE,
    ItemStatus.RECEIVED,
  };

  static const _uncommissionedSgtin = {
    ItemStatus.RESERVED,
    ItemStatus.ALLOCATED,
  };

  Future<List<String>> findIssues({
    required String eventLocationGln,
    required String action,
    String? parentEpcUri,
    List<String> childEpcUris = const [],
  }) async {
    if (action != 'ADD' && action != 'DELETE') return [];

    final packingGln =
        AggregationEventFormValidators.parseGlnToCode(eventLocationGln.trim());
    final issues = <String>[];

    await _checkOperatingGln(packingGln, issues);

    SSCC? parentSscc;
    SGTIN? parentSgtin;
    final parentUri = _resolveEpcUri(parentEpcUri);
    if (parentUri != null) {
      final type = EPCURIConverter.getEPCType(parentUri);
      if (type == 'sscc') {
        parentSscc = await _loadSscc(parentUri);
        if (parentSscc != null) {
          _checkSsccParent(parentSscc, packingGln, issues);
        }
      } else if (type == 'sgtin') {
        parentSgtin = await _loadSgtin(parentUri);
        if (parentSgtin != null) {
          _checkSgtinParent(parentSgtin, packingGln, issues);
        }
      }
    }

    final parentCustodian = parentSscc != null
        ? _ssccCustodian(parentSscc)
        : parentSgtin != null
            ? _sgtinCustodian(parentSgtin)
            : packingGln;
    final parentLocation = parentSscc != null
        ? _ssccLocation(parentSscc)
        : parentSgtin != null
            ? _sgtinLocation(parentSgtin)
            : packingGln;

    for (final rawChild in childEpcUris) {
      final childUri = _resolveEpcUri(rawChild);
      if (childUri == null) continue;
      if (EPCURIConverter.getEPCType(childUri) != 'sgtin') continue;

      final child = await _loadSgtin(childUri);
      if (child == null) continue;

      _checkSgtinChild(
        child,
        childUri,
        packingGln,
        parentCustodian,
        parentLocation,
        issues,
      );
    }

    return issues;
  }

  Future<void> _checkOperatingGln(String packingGln, List<String> issues) async {
    try {
      final gln = await _glnService.getGLNByCode(packingGln);
      if (!gln.active) {
        issues.add(
          'The packing location (GLN: $packingGln) is not active. '
          'Ask your administrator to activate this location in master data before proceeding.',
        );
      }
    } catch (_) {
      issues.add(
        'The packing location (GLN: $packingGln) is not registered in the system. '
        'Ask your administrator to add this location to master data.',
      );
    }
  }

  void _checkSsccParent(SSCC parent, String packingGln, List<String> issues) {
    if (parent.commissionedAt == null &&
        parent.status == LogisticUnitStatus.DRAFT) {
      issues.add(
        'The container (SSCC: ${parent.ssccCode}) has not been commissioned yet. '
        'Commission the container in the SSCC module before using it for packing.',
      );
    }
    if (!_packableSscc.contains(parent.status)) {
      issues.add(
        'The container (SSCC: ${parent.ssccCode}) cannot be packed into because its current status is "${parent.status.name}". '
        'Only containers with an active or in-progress status can receive items. '
        'Containers that are in transit, voided, or decommissioned are not eligible.',
      );
    }
    final custodian = _ssccCustodian(parent);
    if (custodian != null && custodian != packingGln) {
      issues.add(
        'The container (SSCC: ${parent.ssccCode}) is currently held by "$custodian", not by your site ($packingGln). '
        'Transfer custody before packing into this container.',
      );
    }
    final location = _ssccLocation(parent);
    if (location != null && location != packingGln) {
      issues.add(
        'The container (SSCC: ${parent.ssccCode}) is currently at "$location", not at the selected packing location ($packingGln). '
        'Make sure you have selected the correct packing location, or move the container first.',
      );
    }
  }

  void _checkSgtinParent(SGTIN parent, String packingGln, List<String> issues) {
    if (parent.commissionedAt == null ||
        _uncommissionedSgtin.contains(parent.status)) {
      issues.add(
        'The parent item (GTIN: ${parent.gtinCode}, Serial: ${parent.serialNumber}) has not been commissioned. '
        'Commission this item before using it as a parent container.',
      );
    }
    if (!_packableSgtin.contains(parent.status)) {
      issues.add(
        'The parent item (Serial: ${parent.serialNumber}) cannot be used as a container because its status is "${parent.status.name}". '
        'Only active items can be used as parent containers.',
      );
    }
    final custodian = _sgtinCustodian(parent);
    if (custodian != null && custodian != packingGln) {
      issues.add(
        'The parent item (Serial: ${parent.serialNumber}) is currently held by "$custodian", not by your site ($packingGln). '
        'Transfer custody before using this item as a parent container.',
      );
    }
    final location = _sgtinLocation(parent);
    if (location != null && location != packingGln) {
      issues.add(
        'The parent item (Serial: ${parent.serialNumber}) is currently located at "$location", not at your packing location ($packingGln).',
      );
    }
  }

  void _checkSgtinChild(
    SGTIN child,
    String childEpc,
    String packingGln,
    String? parentCustodian,
    String? parentLocation,
    List<String> issues,
  ) {
    if (child.commissionedAt == null ||
        _uncommissionedSgtin.contains(child.status)) {
      issues.add(
        'Item $childEpc has not been commissioned. '
        'Go to the Commissioning module and commission this product serial before packing it.',
      );
    }
    if (!_packableSgtin.contains(child.status)) {
      issues.add(
        'Item $childEpc cannot be packed because its current status is "${child.status.name}". '
        'Items that are in transit, destroyed, stolen, recalled, expired, or flagged under an exception are not eligible for packing.',
      );
    }
    final childCustodian = _sgtinCustodian(child);
    if (childCustodian != null && childCustodian != packingGln) {
      issues.add(
        'Item $childEpc is currently held by "$childCustodian", not by your site ($packingGln). '
        'The item must be under your custody before it can be packed.',
      );
    } else if (parentCustodian != null &&
        childCustodian != null &&
        childCustodian != parentCustodian) {
      issues.add(
        'Item $childEpc is held by "$childCustodian" but the container belongs to "$parentCustodian". '
        'The item and container must be under the same custodian before packing.',
      );
    }
    final childLocation = _sgtinLocation(child);
    if (childLocation != null && childLocation != packingGln) {
      issues.add(
        'Item $childEpc is currently located at "$childLocation", not at your packing location ($packingGln). '
        'Move the item to the correct location before packing.',
      );
    } else if (parentLocation != null &&
        childLocation != null &&
        childLocation != parentLocation) {
      issues.add(
        'Item $childEpc is not in the same location as the container (which is at "$parentLocation"). '
        'The item and container must be at the same location.',
      );
    }
  }

  Future<SSCC?> _loadSscc(String epcUri) async {
    final code = _ssccCodeFromEpc(epcUri);
    if (code == null) return null;
    try {
      return await _ssccService.getSSCCByCode(code);
    } catch (_) {
      return null;
    }
  }

  Future<SGTIN?> _loadSgtin(String epcUri) async {
    final serial = EPCURIConverter.extractSerialFromEPCUri(epcUri);
    final gtin = EPCURIConverter.extractGTINFromEPCUri(epcUri);
    if (serial != null) {
      try {
        return await _sgtinService.getSGTINBySerialNumber(serial);
      } catch (_) {
        // Fall through to GTIN + serial lookup.
      }
    }
    if (gtin != null && serial != null) {
      try {
        final matches = await _sgtinService.findSGTINsByGTIN(gtin);
        for (final candidate in matches) {
          if (candidate.serialNumber == serial) return candidate;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String? _ssccCustodian(SSCC sscc) =>
      _normalizeGln(sscc.currentCustodianGln) ?? _ssccLocation(sscc);

  String? _ssccLocation(SSCC sscc) =>
      _normalizeGln(sscc.currentBizlocationGln) ??
      _normalizeGln(sscc.currentLocationGln) ??
      _normalizeGln(sscc.currentReadpointGln) ??
      _normalizeGln(sscc.shipFromGln);

  String? _sgtinCustodian(SGTIN sgtin) =>
      _normalizeGln(sgtin.currentCustodianGln) ?? _sgtinLocation(sgtin);

  String? _sgtinLocation(SGTIN sgtin) =>
      _normalizeGln(sgtin.currentLocation?.glnCode);

  String? _normalizeGln(String? gln) {
    if (gln == null || gln.trim().isEmpty) return null;
    return AggregationEventFormValidators.parseGlnToCode(gln);
  }

  String? _resolveEpcUri(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    if (trimmed.startsWith('urn:epc:id:')) return trimmed;
    return EPCURIConverter.convertToEPCUri(trimmed) ??
        EPCFormatter.formatToEPCUri(trimmed);
  }

  String? _ssccCodeFromEpc(String epc) {
    final lower = epc.toLowerCase();
    if (lower.startsWith('urn:epc:id:sscc:')) {
      return SsccInputParser.parseToSsccCode(epc);
    }
    final digits = SsccFormat.stripSsccInput(epc);
    if (digits.length == 18) return digits;
    return null;
  }
}
