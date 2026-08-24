import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';

class AggregationPharmaReadinessChecker {
  AggregationPharmaReadinessChecker({
    required GLNService glnService,
    required SGTINService sgtinService,
    required SSCCService ssccService,
  }) : _glnService = glnService,
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

  static const _terminalSscc = {
    LogisticUnitStatus.DECOMMISSIONED,
    LogisticUnitStatus.VOIDED,
  };

  static const _terminalSgtin = {ItemStatus.DESTROYED, ItemStatus.STOLEN};

  Future<List<String>> findIssues({
    required String eventLocationGln,
    required String action,
    String? parentEpcUri,
    List<String> childEpcUris = const [],
  }) async {
    if (action == 'ADD') {
      return _findPackingIssues(
        eventLocationGln: eventLocationGln,
        parentEpcUri: parentEpcUri,
        childEpcUris: childEpcUris,
      );
    }
    if (action == 'DELETE') {
      return _findUnpackingIssues(
        eventLocationGln: eventLocationGln,
        parentEpcUri: parentEpcUri,
        childEpcUris: childEpcUris,
      );
    }
    return [];
  }

  Future<List<String>> _findPackingIssues({
    required String eventLocationGln,
    String? parentEpcUri,
    List<String> childEpcUris = const [],
  }) async {
    final packingGln = AggregationEventFormValidators.parseGlnToCode(
      eventLocationGln.trim(),
    );
    final issues = <String>[];

    await _checkOperatingGln(packingGln, issues, packing: true);

    SSCC? parentSscc;
    SGTIN? parentSgtin;
    final parentUri = _resolveEpcUri(parentEpcUri);
    if (parentUri != null) {
      final type = Gs1Converter.epcType(parentUri);
      if (type == 'sscc') {
        parentSscc = await _loadSscc(parentUri);
        if (parentSscc != null) {
          _checkSsccParentForPacking(parentSscc, packingGln, issues);
        } else {
          issues.add(
            'The parent container ($parentUri) was not found in the system. '
            'Commission or register the SSCC before using it for packing.',
          );
        }
      } else if (type == 'sgtin') {
        parentSgtin = await _loadSgtin(parentUri);
        if (parentSgtin != null) {
          _checkSgtinParentForPacking(parentSgtin, packingGln, issues);
        } else {
          final serial = Gs1Converter.epcToSerial(parentUri);
          issues.add(
            'The parent item${serial != null ? ' (Serial: $serial)' : ''} was not found in the system. '
            'Commission the case or bundle serial before using it as a parent container.',
          );
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
      if (Gs1Converter.epcType(childUri) != 'sgtin') continue;

      final child = await _loadSgtin(childUri);
      if (child == null) continue;

      _checkSgtinChildForPacking(
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

  Future<List<String>> _findUnpackingIssues({
    required String eventLocationGln,
    String? parentEpcUri,
    List<String> childEpcUris = const [],
  }) async {
    final unpackingGln = AggregationEventFormValidators.parseGlnToCode(
      eventLocationGln.trim(),
    );
    final issues = <String>[];

    await _checkOperatingGln(unpackingGln, issues, packing: false);

    final parentUri = _resolveEpcUri(parentEpcUri);
    if (parentUri == null) {
      issues.add(
        'A parent container is required for unpacking. '
        'Scan or enter the SSCC or case serial you are unpacking from.',
      );
      return issues;
    }

    SSCC? parentSscc;
    SGTIN? parentSgtin;
    final type = Gs1Converter.epcType(parentUri);
    if (type == 'sscc') {
      parentSscc = await _loadSscc(parentUri);
      if (parentSscc == null) {
        issues.add(
          'The parent container ($parentUri) was not found in the system. '
          'Confirm the SSCC is registered before unpacking from it.',
        );
        return issues;
      }
      if (_terminalSscc.contains(parentSscc.status)) {
        issues.add(
          'The container (SSCC: ${parentSscc.ssccCode}) cannot be unpacked because its status is "${parentSscc.status.name}". '
          'Voided or decommissioned containers cannot be unpacked.',
        );
        return issues;
      }
    } else if (type == 'sgtin') {
      parentSgtin = await _loadSgtin(parentUri);
      if (parentSgtin == null) {
        final serial = Gs1Converter.epcToSerial(parentUri);
        issues.add(
          'The parent item${serial != null ? ' (Serial: $serial)' : ''} was not found in the system. '
          'Confirm the serial is commissioned before unpacking from it.',
        );
        return issues;
      }
      if (_terminalSgtin.contains(parentSgtin.status)) {
        issues.add(
          'The parent item (Serial: ${parentSgtin.serialNumber}) cannot be unpacked because its status is "${parentSgtin.status.name}".',
        );
        return issues;
      }
    }

    Set<String>? activeChildEpcs;
    if (parentSscc != null) {
      try {
        final links = await _ssccService.getAggregationLinksByCode(
          parentSscc.ssccCode,
        );
        activeChildEpcs = {
          for (final link in links)
            if (link.disaggregatedAt == null && link.active)
              ..._childIdentityKeys(link.childEpc),
        };
      } catch (_) {
        issues.add(
          'Could not verify active aggregation for the parent container. '
          'Confirm the selected children are packed under this container before unpacking.',
        );
        return issues;
      }
    } else if (parentSgtin != null) {
      activeChildEpcs = {
        for (final child in parentSgtin.childEpcs) ..._childIdentityKeys(child),
      };
    }

    for (final rawChild in childEpcUris) {
      final childUri = _resolveEpcUri(rawChild);
      if (childUri == null) continue;
      final childType = Gs1Converter.epcType(childUri);

      if (childType == 'sgtin') {
        final child = await _loadSgtin(childUri);
        if (child == null) {
          issues.add(
            'Item $childUri was not found in the system. '
            'Confirm the product serial exists before unpacking it.',
          );
          continue;
        }
        if (_terminalSgtin.contains(child.status)) {
          issues.add(
            'Item $childUri cannot be unpacked because its status is "${child.status.name}".',
          );
          continue;
        }
        if (activeChildEpcs != null &&
            !_isContainedInActiveSet(childUri, activeChildEpcs)) {
          issues.add(
            'Item $childUri is not currently aggregated under the selected parent. '
            'Only items that are actively packed in this container can be unpacked.',
          );
        }
        continue;
      }

      if (childType == 'sscc') {
        final childSscc = await _loadSscc(childUri);
        if (childSscc == null) {
          issues.add('Child container $childUri was not found in the system.');
          continue;
        }
        if (_terminalSscc.contains(childSscc.status)) {
          issues.add(
            'Child container (SSCC: ${childSscc.ssccCode}) cannot be unpacked because its status is "${childSscc.status.name}".',
          );
          continue;
        }
        if (activeChildEpcs != null &&
            !_isContainedInActiveSet(childUri, activeChildEpcs)) {
          issues.add(
            'Child container $childUri is not currently aggregated under the selected parent.',
          );
        }
      }
    }

    return issues;
  }

  Future<void> _checkOperatingGln(
    String glnCode,
    List<String> issues, {
    required bool packing,
  }) async {
    final role = packing ? 'packing location' : 'unpacking location';
    try {
      final gln = await _glnService.getGLNByCode(glnCode);
      if (!gln.active) {
        issues.add(
          'The $role (GLN: $glnCode) is not active. '
          'Ask your administrator to activate this location in master data before proceeding.',
        );
      }
    } catch (_) {
      issues.add(
        'The $role (GLN: $glnCode) is not registered in the system. '
        'Ask your administrator to add this location to master data.',
      );
    }
  }

  void _checkSsccParentForPacking(
    SSCC parent,
    String packingGln,
    List<String> issues,
  ) {
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

  void _checkSgtinParentForPacking(
    SGTIN parent,
    String packingGln,
    List<String> issues,
  ) {
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

  void _checkSgtinChildForPacking(
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

  Set<String> _childIdentityKeys(String epc) {
    final resolved = _resolveEpcUri(epc) ?? epc.trim();
    final keys = <String>{resolved, epc.trim()};
    final serial = Gs1Converter.epcToSerial(resolved);
    final gtin = Gs1Converter.epcToGTIN(resolved);
    if (serial != null) keys.add(serial);
    if (gtin != null && serial != null) keys.add('$gtin|$serial');
    final sscc = Gs1CanonicalIdentifier.extractSscc18(resolved);
    if (sscc != null) keys.add(sscc);
    return keys;
  }

  bool _isContainedInActiveSet(String childUri, Set<String> activeChildEpcs) {
    return _childIdentityKeys(childUri).any(activeChildEpcs.contains);
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
    final serial = Gs1Converter.epcToSerial(epcUri);
    final gtin = Gs1Converter.epcToGTIN(epcUri);
    if (serial != null) {
      try {
        return await _sgtinService.getSGTINBySerialNumber(serial);
      } catch (_) {}
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
    if (Gs1CanonicalIdentifier.isSerializedInstance(trimmed) ||
        Gs1CanonicalIdentifier.isLotOrClassLevel(trimmed) ||
        Gs1CanonicalIdentifier.isValid(trimmed)) {
      return Gs1CanonicalIdentifier.forStorage(trimmed);
    }
    return Gs1Converter.barcodeToEpc(trimmed) ??
        EPCFormatter.formatToEPCUri(trimmed);
  }

  String? _ssccCodeFromEpc(String epc) {
    return Gs1CanonicalIdentifier.extractSscc18(epc);
  }
}
