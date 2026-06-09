import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';

class CommissioningNavigationButtons extends StatelessWidget {
  const CommissioningNavigationButtons({
    super.key,
    required this.currentStep,
    required this.serialNumbersCount,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentStep;
  final int serialNumbersCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  ResponsiveUtils.paddingAll(context),

      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: CustomOutlinedButtonWidget(
                title: 'Previous',
                onTap: onPrevious,
                height: TraqSpacing.buttonHLarge,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: currentStep < 2
                ? CustomButtonWidget(
                    height: TraqSpacing.buttonHLarge,
                    onTap: onNext,
                    title: 'Next',
                    icon: Icons.arrow_forward,
                  )
                : CustomButtonWidget(
                    height: TraqSpacing.buttonHLarge,
                    onTap: onSubmit,
                    title: 'Commission $serialNumbersCount Items',
                    icon: Icons.check,

                  ),
          ),
        ],
      ),
    );
  }
}
