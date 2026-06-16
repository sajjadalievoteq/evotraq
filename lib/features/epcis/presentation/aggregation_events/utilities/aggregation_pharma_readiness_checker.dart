import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

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
    if (action != 'ADD') return [];

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
          'Location GLN $packingGln is not active — register or activate the site before packing.',
        );
      }
    } catch (_) {
      issues.add(
        'Location GLN $packingGln is not registered — add it to master data first.',
      );
    }
  }

  void _checkSsccParent(SSCC parent, String packingGln, List<String> issues) {
    if (parent.commissionedAt == null ||
        parent.status == LogisticUnitStatus.DRAFT ||
        parent.status == LogisticUnitStatus.ALLOCATED) {
      issues.add(
        'Parent SSCC ${parent.ssccCode} is not commissioned — commission the container before packing.',
      );
    }
    if (!_packableSscc.contains(parent.status)) {
      issues.add(
        'Parent SSCC ${parent.ssccCode} cannot be packed (status: ${parent.status.name}). '
        'Containers that are traveling, voided, or decommissioned cannot accept children.',
      );
    }
    final custodian = _ssccCustodian(parent);
    if (custodian != null && custodian != packingGln) {
      issues.add(
        'Parent SSCC ${parent.ssccCode} is not under your custody at $packingGln (custodian: $custodian).',
      );
    }
    final location = _ssccLocation(parent);
    if (location != null && location != packingGln) {
      issues.add(
        'Parent SSCC ${parent.ssccCode} is not at the packing location $packingGln (currently at $location).',
      );
    }
  }

  void _checkSgtinParent(SGTIN parent, String packingGln, List<String> issues) {
    if (parent.commissionedAt == null ||
        _uncommissionedSgtin.contains(parent.status)) {
      issues.add(
        'Parent item ${parent.gtinCode}/${parent.serialNumber} is not commissioned.',
      );
    }
    if (!_packableSgtin.contains(parent.status)) {
      issues.add(
        'Parent item ${parent.serialNumber} cannot be used as a container (status: ${parent.status.name}).',
      );
    }
    final custodian = _sgtinCustodian(parent);
    if (custodian != null && custodian != packingGln) {
      issues.add(
        'Parent item ${parent.serialNumber} is not under your custody at $packingGln (custodian: $custodian).',
      );
    }
    final location = _sgtinLocation(parent);
    if (location != null && location != packingGln) {
      issues.add(
        'Parent item ${parent.serialNumber} is not at packing location $packingGln (at $location).',
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
        'Child $childEpc is not commissioned — commission the serialised unit first.',
      );
    }
    if (!_packableSgtin.contains(child.status)) {
      issues.add(
        'Child $childEpc cannot be packed (status: ${child.status.name}). '
        'Items in transit, destroyed, stolen, recalled, expired, or under exception cannot be packed.',
      );
    }
    final childCustodian = _sgtinCustodian(child);
    if (childCustodian != null && childCustodian != packingGln) {
      issues.add(
        'Child $childEpc is not under your custody at $packingGln (custodian: $childCustodian).',
      );
    } else if (parentCustodian != null &&
        childCustodian != null &&
        childCustodian != parentCustodian) {
      issues.add(
        'Child $childEpc custodian ($childCustodian) does not match parent container ($parentCustodian).',
      );
    }
    final childLocation = _sgtinLocation(child);
    if (childLocation != null && childLocation != packingGln) {
      issues.add(
        'Child $childEpc is not at packing location $packingGln (at $childLocation).',
      );
    } else if (parentLocation != null &&
        childLocation != null &&
        childLocation != parentLocation) {
      issues.add(
        'Child $childEpc is not at the same location as the parent container ($parentLocation).',
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
    if (serial == null) return null;
    try {
      return await _sgtinService.getSGTINBySerialNumber(serial);
    } catch (_) {
      return null;
    }
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
      final body = epc.substring('urn:epc:id:sscc:'.length);
      final parts = body.split('.');
      if (parts.length == 2) return parts[0] + parts[1];
    }
    final digits = SsccFormat.stripSsccInput(epc);
    if (digits.length == 18) return digits;
    return null;
  }
}
