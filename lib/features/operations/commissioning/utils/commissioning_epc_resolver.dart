import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_pool_match.dart';

sealed class CommissioningEpcResolveOutcome {}

class CommissioningEpcResolved extends CommissioningEpcResolveOutcome {
  CommissioningEpcResolved(this.parsed);

  final EPCParseResult parsed;
}

class CommissioningEpcResolveError extends CommissioningEpcResolveOutcome {
  CommissioningEpcResolveError(this.message);

  final String message;
}

class CommissioningEpcResolveAmbiguous extends CommissioningEpcResolveOutcome {
  CommissioningEpcResolveAmbiguous(this.matches);

  final List<CommissioningPoolMatch> matches;
}

/// Parses commissioning input and resolves bare serials against the serial pool.
class CommissioningEpcResolver {
  const CommissioningEpcResolver({
    required SGTINService sgtinService,
    required SSCCService ssccService,
  })  : _sgtinService = sgtinService,
        _ssccService = ssccService;

  final SGTINService _sgtinService;
  final SSCCService _ssccService;

  Future<CommissioningEpcResolveOutcome> resolve(String rawInput) async {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return CommissioningEpcResolveError('EPC input is empty');
    }

    try {
      final parsed = parseToEPC(trimmed);
      if (parsed.type == EPCType.gtin || parsed.type == EPCType.unknown) {
        return CommissioningEpcResolveError(
          parsed.type == EPCType.gtin
              ? 'GTIN-only input is not sufficient — include the serial (AI 21) or scan a complete SGTIN'
              : 'Could not determine identifier type from input',
        );
      }
      return CommissioningEpcResolved(parsed);
    } on EPCParseException {
      if (_looksStructured(trimmed)) {
        return CommissioningEpcResolveError(
          'Could not parse GS1 identifier from input',
        );
      }
      return _resolveBareSerial(trimmed);
    }
  }

  Future<CommissioningEpcResolveOutcome> _resolveBareSerial(
    String serial,
  ) async {
    final sgtinMatches = await _searchSgtinBySerial(serial);
    final ssccMatch = await _searchSsccByCode(serial);

    final matches = <CommissioningPoolMatch>[
      ...sgtinMatches,
      ?ssccMatch,
    ];

    if (matches.isEmpty) {
      return CommissioningEpcResolveError('Serial not pre-allocated');
    }
    if (matches.length == 1) {
      return CommissioningEpcResolved(matches.first.parsed);
    }
    return CommissioningEpcResolveAmbiguous(matches);
  }

  Future<List<CommissioningPoolMatch>> _searchSgtinBySerial(
    String serial,
  ) async {
    final result = await _sgtinService.searchSGTINsAdvanced(
      serialNumber: serial,
      page: 0,
      size: 10,
    );
    final content =
        (result['content'] as List?)?.whereType<SGTIN>().toList() ??
            const <SGTIN>[];

    return content.map((sgtin) {
      final epc = sgtin.epcUri ??
          Gs1Converter.gtinSerialToEpc(sgtin.gtinCode, sgtin.serialNumber) ??
          'urn:epc:id:sgtin:.${sgtin.serialNumber}';
      final parsed = EPCParseResult(
        type: EPCType.sgtin,
        epc: epc,
        gtin: sgtin.gtinCode,
        serial: sgtin.serialNumber,
        raw: serial,
        detectedFormat: 'Pool lookup (bare serial)',
      );
      return CommissioningPoolMatch(
        parsed: parsed,
        label: 'SGTIN ${sgtin.gtinCode} / ${sgtin.serialNumber} (${sgtin.status.name})',
        sourceStatus: sgtin.status.name,
      );
    }).toList();
  }

  Future<CommissioningPoolMatch?> _searchSsccByCode(String input) async {
    final stripped = SsccFormat.stripSsccInput(input);
    if (stripped.length != 18 || !SsccFormat.isValidSscc(stripped)) {
      return null;
    }
    try {
      final sscc = await _ssccService.getSSCCByCode(stripped);
      final epc = sscc.ssccUri ??
          Gs1Converter.ssccToEpc(stripped) ??
          'urn:epc:id:sscc:$stripped';
      return CommissioningPoolMatch(
        parsed: EPCParseResult(
          type: EPCType.sscc,
          epc: epc,
          sscc: stripped,
          raw: input,
          detectedFormat: 'Pool lookup (bare SSCC)',
          companyPrefix: sscc.gs1CompanyPrefix,
        ),
        label: 'SSCC $stripped (${sscc.status.name})',
        sourceStatus: sscc.status.name,
      );
    } catch (_) {
      return null;
    }
  }

  bool _looksStructured(String value) {
    if (value.startsWith('urn:') ||
        value.startsWith('http://') ||
        value.startsWith('https://')) {
      return true;
    }
    if (value.contains('(') && value.contains(')')) return true;
    if (value.startsWith('00') && value.length >= 18) return true;
    final digits = GtinFormat.stripGtinInput(value);
    if (RegExp(r'^\d{8,14}$').hasMatch(digits)) return true;
  return RegExp(r'^\d{14}\s+\S').hasMatch(value);
  }
}
