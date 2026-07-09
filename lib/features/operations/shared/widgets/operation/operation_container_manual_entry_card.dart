import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';

class OperationContainerManualEntryCard extends StatelessWidget {
  const OperationContainerManualEntryCard({
    super.key,
    required this.onContainerAdded,
  });

  final void Function(EPCParseResult result) onContainerAdded;

  @override
  Widget build(BuildContext context) {
    return EPCInputWidget(
      label: 'Container SSCC / SGTIN',
      placeholder: 'SSCC (carton/pallet) or SGTIN product serial',
      allowedTypes: const [EPCType.sscc, EPCType.sgtin],
      scannerAvailable: false,
      onItemAdded: onContainerAdded,
    );
  }
}
