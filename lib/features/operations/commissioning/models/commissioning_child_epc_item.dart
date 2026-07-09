import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';

/// Child SGTIN linked to an SSCC parent for aggregation after commissioning.
class CommissioningChildEpcItem {
  const CommissioningChildEpcItem({
    required this.parsed,
    this.statusWarning,
  });

  final EPCParseResult parsed;
  final String? statusWarning;

  String get epc => parsed.epc;

  String get displayKey =>
      parsed.serial ?? parsed.gtin ?? parsed.epc;
}
