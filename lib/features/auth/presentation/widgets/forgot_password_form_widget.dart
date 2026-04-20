import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_input_field.dart';

class ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isSubmitting;
  final bool hasRequiredInput;
  final VoidCallback onSubmit;
  final VoidCallback onFormChanged;

  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isSubmitting,
    required this.hasRequiredInput,
    required this.onSubmit,
    required this.onFormChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = ColorManager.primary(context);
    final textPrimary = ColorManager.textPrimary(context);
    final textSecondary = ColorManager.textSecondary(context);

    return Form(
      key: formKey,
      onChanged: onFormChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Icon
          Icon(Icons.lock_reset, size: 80, color: primary),

          const SizedBox(height: 24),

          // Title
          Text(
            'Reset Your Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Enter your email address and we will send you instructions to reset your password.',
            style: TextStyle(fontSize: 16, color: textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Email Field
          AuthInputField(
            controller: emailController,
            labelText: 'Email',
            type: AuthInputFieldType.email,
            enabled: !isSubmitting,
            onFieldSubmitted: (_) => onSubmit(),
          ),

          const SizedBox(height: 32),

          // Submit Button
          AuthActionButton(
            label: 'SEND RESET INSTRUCTIONS',
            isLoading: isSubmitting,
            isEnabled: hasRequiredInput && !isSubmitting,
            onPressed: onSubmit,
          ),

          const SizedBox(height: 16),

          // Back to Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Remember your password?',
                style: TextStyle(color: textPrimary),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
