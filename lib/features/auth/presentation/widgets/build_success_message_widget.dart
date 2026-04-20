import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_action_button.dart';

class BuildSuccessMessage extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const BuildSuccessMessage({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primary = ColorManager.primary(context);
    final textSecondary = ColorManager.textSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

        // Success Icon
        Icon(
          Icons.check_circle,
          size: 100,
          color: ColorManager.success(context),
        ),

        const SizedBox(height: 32),

        // Success Message
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Action Button
        AuthActionButton(
          label: buttonLabel,
          onPressed: onButtonPressed,
        ),
      ],
    );
  }
}
