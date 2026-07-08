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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: EPCInputWidget(
          label: 'Container SSCC / Barcode',
          placeholder: 'Enter the SSCC or container barcode',
          allowedTypes: const [EPCType.sscc],
          onItemAdded: onContainerAdded,
        ),
      ),
    );
  }
}
