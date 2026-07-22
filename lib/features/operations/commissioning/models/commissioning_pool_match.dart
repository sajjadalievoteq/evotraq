import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_checker.dart';


class CommissioningPoolMatch {
  const CommissioningPoolMatch({
    required this.parsed,
    required this.label,
    this.sourceStatus,
    this.poolCheck,
  });

  final EPCParseResult parsed;
  final String label;
  final String? sourceStatus;
  final CommissioningPoolCheckResult? poolCheck;
}
