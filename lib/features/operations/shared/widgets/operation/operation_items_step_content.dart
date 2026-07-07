import 'package:flutter/material.dart';

/// Shared Column wrapper for desktop wizard steps that combine details + items.
class OperationItemsStepContent extends StatelessWidget {
  const OperationItemsStepContent({
    super.key,
    required this.detailsStep,
    required this.itemsStep,
  });

  final Widget detailsStep;
  final Widget itemsStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        detailsStep,
        itemsStep,
      ],
    );
  }
}
