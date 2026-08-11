import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';

class Gs1SubmitButton extends StatelessWidget {
  const Gs1SubmitButton({
    super.key,
    required this.loading,
    required this.onPressed,
    this.label = 'Run',
  });

  final bool loading;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: TraqSpacing.lg),
      child: CustomElevatedButton(
        label: label,
        isLoading: loading,
        isEnabled: !loading,
        onPressed: onPressed,
      ),
    );
  }
}
