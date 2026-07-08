import 'package:flutter/material.dart';

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
