import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';

class OperationItemManualEntryCard extends StatelessWidget {
  const OperationItemManualEntryCard({
    super.key,
    required this.onItemAdded,
    this.allowedTypes,
  });

  final void Function(EPCParseResult result) onItemAdded;
  final List<EPCType>? allowedTypes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: EPCInputWidget(
          label: 'Item Barcode',
          placeholder: 'Enter SGTIN or SSCC barcode',
          allowedTypes: allowedTypes ?? const [EPCType.sgtin, EPCType.sscc],
          scannerAvailable: false,
          onItemAdded: onItemAdded,
        ),
      ),
    );
  }
}
