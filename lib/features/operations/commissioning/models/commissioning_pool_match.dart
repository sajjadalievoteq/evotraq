import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';

/// A single serial-pool candidate when bare-serial resolution is ambiguous.
class CommissioningPoolMatch {
  const CommissioningPoolMatch({
    required this.parsed,
    required this.label,
    this.sourceStatus,
  });

  final EPCParseResult parsed;
  final String label;
  final String? sourceStatus;
}
