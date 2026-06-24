import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_stepper_header.dart';

/// Column layout combining animated stepper, paged content, and footer navigation.
class OperationWizard extends StatelessWidget {
  const OperationWizard({
    super.key,
    required this.currentStep,
    required this.steps,
    required this.pageController,
    required this.children,
    required this.footer,
    this.onPageChanged,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final int currentStep;
  final List<OperationStepConfig> steps;
  final PageController pageController;
  final List<Widget> children;
  final Widget footer;
  final ValueChanged<int>? onPageChanged;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OperationStepperHeader(
          currentStep: currentStep,
          steps: steps,
        ),
        Expanded(
          child: PageView(
            controller: pageController,
            physics: physics,
            onPageChanged: onPageChanged,
            children: children,
          ),
        ),
        footer,
      ],
    );
  }
}
