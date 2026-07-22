import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_pool_match.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_checker.dart';

sealed class CommissioningEpcResolveOutcome {}

class CommissioningEpcResolved extends CommissioningEpcResolveOutcome {
  CommissioningEpcResolved(this.parsed, {this.poolCheck});

  final EPCParseResult parsed;
  final CommissioningPoolCheckResult? poolCheck;
}

class CommissioningEpcResolveError extends CommissioningEpcResolveOutcome {
  CommissioningEpcResolveError(this.message);

  final String message;
}

class CommissioningEpcResolveAmbiguous extends CommissioningEpcResolveOutcome {
  CommissioningEpcResolveAmbiguous(this.matches);

  final List<CommissioningPoolMatch> matches;
}


class CommissioningEpcResolver {
  const CommissioningEpcResolver({
    required SGTINService sgtinService,
    required SSCCService ssccService,
    required CommissioningSerialPoolChecker poolChecker,
  })  : _sgtinService = sgtinService,
        _ssccService = ssccService,
        _poolChecker = poolChecker;

  final SGTINService _sgtinService;
  final SSCCService _ssccService;
  final CommissioningSerialPoolChecker _poolChecker;

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
    final results = await Future.wait([
      _searchSgtinBySerial(serial),
      _searchSsccByCode(serial),
    ]);
    final sgtinMatches = results[0] as List<CommissioningPoolMatch>;
    final ssccMatch = results[1] as CommissioningPoolMatch?;

    final matches = <CommissioningPoolMatch>[
      ...sgtinMatches,
      ?ssccMatch,
    ];

    if (matches.isEmpty) {
      return CommissioningEpcResolveError('Serial not pre-allocated');
    }
    if (matches.length == 1) {
      final match = matches.first;
      return CommissioningEpcResolved(
        match.parsed,
        poolCheck: match.poolCheck,
      );
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
      final epc = sgtin.canonicalIdentifier ??
          Gs1Converter.gtinSerialToEpc(sgtin.gtinCode, sgtin.serialNumber) ??
          'https://id.gs1.org/01/${sgtin.gtinCode.padLeft(14, '0')}/21/${sgtin.serialNumber}';
      final parsed = EPCParseResult(
        type: EPCType.sgtin,
        epc: epc,
        gtin: sgtin.gtinCode,
        serial: sgtin.serialNumber,
        raw: serial,
        detectedFormat: 'Pool lookup (bare serial)',
      );
      final poolCheck = _poolChecker.resultFromSgtin(sgtin);
      return CommissioningPoolMatch(
        parsed: parsed,
        label:
            'SGTIN ${sgtin.gtinCode} / ${sgtin.serialNumber} (${sgtin.status.name})',
        sourceStatus: sgtin.status.name,
        poolCheck: poolCheck,
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
      final epc = sscc.canonicalIdentifier ??
          Gs1Converter.ssccToEpc(stripped) ??
          'https://id.gs1.org/00/$stripped';
      final parsed = EPCParseResult(
        type: EPCType.sscc,
        epc: epc,
        sscc: stripped,
        raw: input,
        detectedFormat: 'Pool lookup (bare SSCC)',
        companyPrefix: sscc.gs1CompanyPrefix,
      );
      return CommissioningPoolMatch(
        parsed: parsed,
        label: 'SSCC $stripped (${sscc.status.name})',
        sourceStatus: sscc.status.name,
        poolCheck: _poolChecker.resultFromSscc(sscc),
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
