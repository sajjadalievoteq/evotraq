import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation/widgets/return_receiving_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation/widgets/return_receiving_reference_details_step.dart';

/// Combined container + items step content for desktop ReturnReceiving wizard.
class ReturnReceivingOperationItemsStepContent extends StatelessWidget {
  const ReturnReceivingOperationItemsStepContent({
    super.key,
    required this.containerStep,
    required this.itemsStep,
  });

  final ReturnReceivingReferenceDetailsStep containerStep;
  final ReturnReceivingItemScanStep itemsStep;

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
