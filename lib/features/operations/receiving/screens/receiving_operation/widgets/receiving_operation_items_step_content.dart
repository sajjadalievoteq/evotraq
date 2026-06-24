import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_reference_details_step.dart';

/// Combined container + items step content for desktop Receiving wizard.
class ReceivingOperationItemsStepContent extends StatelessWidget {
  const ReceivingOperationItemsStepContent({
    super.key,
    required this.containerStep,
    required this.itemsStep,
  });

  final ReceivingReferenceDetailsStep containerStep;
  final ReceivingItemScanStep itemsStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        containerStep,
         // const SizedBox(height: 16),
        itemsStep,
      ],
    );
  }
}
