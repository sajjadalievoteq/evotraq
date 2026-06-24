import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_wizard.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_wizard_nav_buttons.dart';
import 'package:traqtrace_app/core/widgets/loading_overlay.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';

/// Mobile wizard layout for Receiving operation screen.
class ReceivingOperationMobileLayout extends StatelessWidget {
  const ReceivingOperationMobileLayout({
    super.key,
    required this.isLoading,
    required this.currentStep,
    required this.steps,
    required this.pageController,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
    required this.stepPages,
  });

  final bool isLoading;
  final int currentStep;
  final List<OperationStepConfig> steps;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final List<Widget> stepPages;

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: TraqAppBar(
          context,
          title: Text(
            'Receiving Operation',
            style: context.text.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        drawer: const AppDrawer(),
        body: SafeArea(
          top: false,
          child: OperationWizard(
            currentStep: currentStep,
            steps: steps,
            pageController: pageController,
            onPageChanged: onPageChanged,
            children: stepPages,
            footer: OperationWizardNavButtons(
              currentStep: currentStep,
              finalStepIndex: steps.length - 1,
              onPrevious: onPrevious,
              onNext: onNext,
              onSubmit: onSubmit,
              submitLabel: 'Create Receiving Operation',
            ),
          ),
        ),
      ),
    );
  }
}
