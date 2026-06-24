import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_wizard.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_wizard_nav_buttons.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_scanning_mode.dart';

class CommissioningOperationMobileLayout extends StatelessWidget {
  const CommissioningOperationMobileLayout({
    super.key,
    required this.currentStep,
    required this.wizardSteps,
    required this.pageController,
    required this.scanningMode,
    required this.wiredScannerFocusNode,
    required this.step1Widget,
    required this.step2Widget,
    required this.step3Widget,
    required this.serialCount,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentStep;
  final List<OperationStepConfig> wizardSteps;
  final PageController pageController;
  final CommissioningScanningMode scanningMode;
  final FocusNode wiredScannerFocusNode;
  final Widget step1Widget;
  final Widget step2Widget;
  final Widget step3Widget;
  final int serialCount;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrevious;
  final Future<void> Function() onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return OperationWizard(
      currentStep: currentStep,
      steps: wizardSteps,
      pageController: pageController,
      onPageChanged: (page) {
        onPageChanged(page);
        if (page == 1 && scanningMode == CommissioningScanningMode.wired) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => wiredScannerFocusNode.requestFocus(),
          );
        }
      },
      children: [step1Widget, step2Widget, step3Widget],
      footer: OperationWizardNavButtons(
        currentStep: currentStep,
        finalStepIndex: wizardSteps.length - 1,
        previousLabel: 'Previous',
        onPrevious: onPrevious,
        onNext: onNext,
        onSubmit: onSubmit,
        submitLabel: 'Commission $serialCount Items',
      ),
    );
  }
}
