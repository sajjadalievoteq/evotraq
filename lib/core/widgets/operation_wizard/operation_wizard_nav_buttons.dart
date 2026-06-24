import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';

/// Previous / Next / Submit navigation bar for operation wizards.
class OperationWizardNavButtons extends StatelessWidget {
  const OperationWizardNavButtons({
    super.key,
    required this.onSubmit,
    required this.submitLabel,
    this.submitOnly = false,
    this.currentStep = 0,
    this.finalStepIndex = 0,
    this.onPrevious,
    this.onNext,
    this.nextLabel = 'Next',
    this.previousLabel = 'Back',
  }) : assert(
          submitOnly || (onPrevious != null && onNext != null),
          'onPrevious and onNext are required unless submitOnly is true',
        );

  final bool submitOnly;
  final int currentStep;
  final int finalStepIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onSubmit;
  final String submitLabel;
  final String nextLabel;
  final String previousLabel;

  bool get _isFinalStep => submitOnly || currentStep == finalStepIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.paddingAll(context),
      child: Row(
        children: [
          if (!submitOnly && currentStep > 0) ...[
            Expanded(
              child: CustomOutlinedButtonWidget(
                title: previousLabel,
                onTap: onPrevious!,
                height: TraqSpacing.buttonHLarge,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: submitOnly ? 1 : 2,
            child: _isFinalStep
                ? CustomButtonWidget(
                    height: TraqSpacing.buttonHLarge,
                    onTap: onSubmit,
                    title: submitLabel,
                    icon: Icons.check,
                  )
                : CustomButtonWidget(
                    height: TraqSpacing.buttonHLarge,
                    onTap: onNext!,
                    title: nextLabel,
                    icon: Icons.arrow_forward,
                  ),
          ),
        ],
      ),
    );
  }
}
