import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_wizard_nav_buttons.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_panel.dart';
import 'package:traqtrace_app/core/widgets/loading_overlay.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';

/// Desktop three-column layout for shipping operation wizard.
class ShippingOperationDesktopLayout extends StatelessWidget {
  const ShippingOperationDesktopLayout({
    super.key,
    required this.isLoading,
    required this.step1Complete,
    required this.step2Complete,
    required this.detailsStep,
    required this.itemsStep,
    required this.reviewStep,
    required this.onSubmit,
  });

  final bool isLoading;
  final bool step1Complete;
  final bool step2Complete;
  final Widget detailsStep;
  final Widget itemsStep;
  final Widget reviewStep;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final step3Locked = !step1Complete || !step2Complete;

    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text('New Shipping Operation'),
      ),
      drawer: const AppDrawer(),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: OperationStepPanel(
                stepNumber: 1,
                title: 'Reference Details',
                isComplete: step1Complete,
                isLocked: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: detailsStep,
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: OperationStepPanel(
                stepNumber: 2,
                title: 'Items',
                isComplete: step2Complete,
                isLocked: !step1Complete,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: itemsStep,
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: OperationStepPanel(
                stepNumber: 3,
                title: 'Review & Submit',
                isComplete: false,
                isLocked: step3Locked,
                footer: OperationWizardNavButtons(
                  submitOnly: true,
                  onSubmit: onSubmit,
                  submitLabel: 'Create Shipping Operation',
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: reviewStep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
