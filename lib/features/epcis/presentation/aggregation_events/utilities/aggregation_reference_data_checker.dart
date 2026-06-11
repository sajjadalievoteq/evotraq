import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_missing_reference.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

/// Verifies GLN, GTIN, SGTIN, and SSCC master data exists before aggregation save.
class AggregationReferenceDataChecker {
  AggregationReferenceDataChecker({
    required GLNService glnService,
    required GTINService gtinService,
    required SGTINService sgtinService,
    required SSCCService ssccService,
    required ReferenceDataValidationService referenceDataValidationService,
  })  : _glnService = glnService,
        _gtinService = gtinService,
        _sgtinService = sgtinService,
        _ssccService = ssccService,
        _referenceDataValidationService = referenceDataValidationService;

  final GLNService _glnService;
  final GTINService _gtinService;
  final SGTINService _sgtinService;
  final SSCCService _ssccService;
  final ReferenceDataValidationService _referenceDataValidationService;

  Future<List<AggregationMissingReference>> findMissing({
    required String locationGlnCode,
    String? parentEpcUri,
    List<String> childEpcUris = const [],
  }) async {
    final missing = <AggregationMissingReference>[];
    final seen = <String>{};

    void track(AggregationMissingReference item) {
      final key = '${item.kind.name}:${item.displayValue}';
      if (seen.add(key)) {
        missing.add(item);
      }
    }

    await _ensureGln(locationGlnCode, track);

    if (parentEpcUri != null && parentEpcUri.trim().isNotEmpty) {
      await _ensureEpc(
        parentEpcUri,
        track,
        contextLabel: 'Parent pack',
      );
    }

    for (final child in childEpcUris) {
      if (child.trim().isEmpty) continue;
      await _ensureEpc(
        child,
        track,
        contextLabel: 'Child EPC',
      );
    }

    missing.sort(
      (a, b) => a.sortOrder.compareTo(b.sortOrder),
    );
    return missing;
  }

  Future<void> _ensureGln(
    String glnCode,
    void Function(AggregationMissingReference item) track,
  ) async {
    final normalized =
        AggregationEventFormValidators.parseGlnToCode(glnCode.trim());
    if (await _glnExists(normalized)) return;

    track(
      AggregationMissingReference(
        kind: AggregationReferenceKind.gln,
        displayValue: normalized,
        createRoute: Constants.gs1GlnNewRoute,
        contextLabel: 'Event location',
      ),
    );
  }

  Future<void> _ensureEpc(
    String rawEpc,
    void Function(AggregationMissingReference item) track, {
    required String contextLabel,
  }) async {
    final uri = _resolveEpcUri(rawEpc);
    if (uri == null || uri.isEmpty) return;

    final type = EPCURIConverter.getEPCType(uri);
    if (type == 'sscc') {
      await _ensureSscc(uri, track, contextLabel: contextLabel);
    } else if (type == 'sgtin') {
      await _ensureSgtin(uri, track, contextLabel: contextLabel);
    }
  }

  Future<void> _ensureSscc(
    String epcUri,
    void Function(AggregationMissingReference item) track, {
    required String contextLabel,
  }) async {
    final ssccCode = _ssccCodeFromEpc(epcUri);
    if (ssccCode == null) return;
    if (await _ssccExists(ssccCode, epcUri)) return;

    track(
      AggregationMissingReference(
        kind: AggregationReferenceKind.sscc,
        displayValue: ssccCode,
        createRoute: Constants.gs1SsccNewRoute,
        contextLabel: contextLabel,
      ),
    );
  }

  Future<void> _ensureSgtin(
    String epcUri,
    void Function(AggregationMissingReference item) track, {
    required String contextLabel,
  }) async {
    final gtin = EPCURIConverter.extractGTINFromEPCUri(epcUri);
    final serial = EPCURIConverter.extractSerialFromEPCUri(epcUri);
    if (gtin == null || serial == null) return;

    await _ensureGtin(gtin, track, contextLabel: contextLabel);

    if (await _sgtinExists(epcUri, gtin, serial)) return;

    track(
      AggregationMissingReference(
        kind: AggregationReferenceKind.sgtin,
        displayValue: '$gtin / $serial',
        createRoute: Constants.gs1SgtinNewRoute,
        contextLabel: contextLabel,
      ),
    );
  }

  Future<void> _ensureGtin(
    String gtin,
    void Function(AggregationMissingReference item) track, {
    required String contextLabel,
  }) async {
    final normalized = gtin.replaceAll(RegExp(r'\D'), '');
    if (normalized.isEmpty) return;

    if (await _gtinExists(normalized)) return;

    track(
      AggregationMissingReference(
        kind: AggregationReferenceKind.gtin,
        displayValue: normalized,
        createRoute: Constants.gs1GtinNewRoute,
        contextLabel: contextLabel,
      ),
    );
  }

  String? _resolveEpcUri(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('urn:epc:id:')) return trimmed;

    final fromConverter = EPCURIConverter.convertToEPCUri(trimmed);
    if (fromConverter != null) return fromConverter;

    return EPCFormatter.formatToEPCUri(trimmed);
  }

  Future<bool> _glnExists(String glnCode) async {
    try {
      await _glnService.getGLNByCode(glnCode);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _gtinExists(String gtinCode) async {
    try {
      await _gtinService.getGTIN(gtinCode);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _ssccExists(String ssccCode, String epcUri) async {
    try {
      await _ssccService.getSSCCByCode(ssccCode);
      return true;
    } catch (_) {
      try {
        final result =
            await _referenceDataValidationService.validateSSCC(epcUri);
        return result.exists;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> _sgtinExists(String epcUri, String gtin, String serial) async {
    final normalizedGtin = gtin.replaceAll(RegExp(r'\D'), '').padLeft(14, '0');
    try {
      final record = await _sgtinService.getSGTINBySerialNumber(serial);
      final recordGtin =
          record.gtinCode.replaceAll(RegExp(r'\D'), '').padLeft(14, '0');
      return recordGtin == normalizedGtin;
    } catch (_) {
      try {
        final result =
            await _referenceDataValidationService.validateSGTIN(epcUri);
        return result.exists;
      } catch (_) {
        return false;
      }
    }
  }

  String? _ssccCodeFromEpc(String epc) {
    final lower = epc.toLowerCase();
    if (lower.startsWith('urn:epc:id:sscc:')) {
      final body = epc.substring('urn:epc:id:sscc:'.length);
      final parts = body.split('.');
      if (parts.length == 2) {
        return parts[0] + parts[1];
      }
      return null;
    }

    final digits = SsccFormat.stripSsccInput(epc);
    if (digits.length == 18) return digits;
    return null;
  }
}
