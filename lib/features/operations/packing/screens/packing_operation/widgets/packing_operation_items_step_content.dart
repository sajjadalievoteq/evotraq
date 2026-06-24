import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_reference_details_step.dart';

/// Combined container + items step content for desktop packing wizard.
class PackingOperationItemsStepContent extends StatelessWidget {
  const PackingOperationItemsStepContent({
    super.key,
    required this.containerStep,
    required this.itemsStep,
  });

  final PackingReferenceDetailsStep containerStep;
  final PackingItemScanStep itemsStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        containerStep,
         const SizedBox(height: 16),
        itemsStep,
      ],
    );
  }
}
