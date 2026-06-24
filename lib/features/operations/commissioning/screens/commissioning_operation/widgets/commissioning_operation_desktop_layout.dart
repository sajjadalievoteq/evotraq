import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_panel.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_wizard_nav_buttons.dart';

class CommissioningOperationDesktopLayout extends StatelessWidget {
  const CommissioningOperationDesktopLayout({
    super.key,
    required this.step1Complete,
    required this.step2Complete,
    required this.step1Widget,
    required this.step2Widget,
    required this.step3Widget,
    required this.serialCount,
    required this.onSubmit,
  });

  final bool step1Complete;
  final bool step2Complete;
  final Widget step1Widget;
  final Widget step2Widget;
  final Widget step3Widget;
  final int serialCount;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final step3Locked = !step1Complete || !step2Complete;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: OperationStepPanel(
            stepNumber: 1,
            title: 'Product Details',
            isComplete: step1Complete,
            isLocked: false,
            child: step1Widget,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: OperationStepPanel(
            stepNumber: 2,
            title: 'Serial Numbers',
            isComplete: step2Complete,
            isLocked: !step1Complete,
            child: step2Widget,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: OperationStepPanel(
            stepNumber: 3,
            title: 'Review & Submit',
            isComplete: false,
            isLocked: step3Locked,
            footer: OperationWizardNavButtons(
              submitOnly: true,
              onSubmit: onSubmit,
              submitLabel: 'Commission $serialCount Items',
            ),
            child: step3Widget,
          ),
        ),
      ],
    );
  }
}
