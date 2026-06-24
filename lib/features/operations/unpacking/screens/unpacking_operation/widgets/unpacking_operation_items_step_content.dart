import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_reference_details_step.dart';

/// Combined container + items step content for desktop unpacking wizard.
class UnpackingOperationItemsStepContent extends StatelessWidget {
  const UnpackingOperationItemsStepContent({
    super.key,
    required this.containerStep,
    required this.itemsStep,
  });

  final UnpackingReferenceDetailsStep containerStep;
  final UnpackingItemScanStep itemsStep;

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
