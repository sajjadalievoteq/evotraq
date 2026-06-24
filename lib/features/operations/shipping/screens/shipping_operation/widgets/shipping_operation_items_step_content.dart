import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_reference_details_step.dart';

/// Combined container + items step content for desktop shipping wizard.
class ShippingOperationItemsStepContent extends StatelessWidget {
  const ShippingOperationItemsStepContent({
    super.key,
    required this.containerStep,
    required this.itemsStep,
  });

  final ShippingReferenceDetailsStep containerStep;
  final ShippingItemScanStep itemsStep;

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
