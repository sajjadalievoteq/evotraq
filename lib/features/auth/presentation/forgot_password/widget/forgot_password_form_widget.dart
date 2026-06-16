import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_input_field.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';

import '../../../../../core/config/constants.dart';

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
    final c = context.colors;
    final primary = c.primary;
    final textPrimary = c.textPrimary;
    final textSecondary = c.textSecondary;

    return Form(
      key: formKey,
      onChanged: onFormChanged,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          SvgPicture.asset(
            AppAssets.iconLock,
            width: 80,
            height: 80,
            colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
          ),

          const SizedBox(height: 24),

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

          Text(
            'Enter your email address and we will send you instructions to reset your password.',
            style: TextStyle(fontSize: 16, color: textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          AuthInputField(
            controller: emailController,
            labelText: 'Email',
            type: AuthInputFieldType.email,
            enabled: !isSubmitting,
            onFieldSubmitted: (_) => onSubmit(),
          ),

          const SizedBox(height: 32),

          AuthActionButton(
            label: 'SEND RESET INSTRUCTIONS',
            isLoading: isSubmitting,
            isEnabled: hasRequiredInput && !isSubmitting,
            onPressed: onSubmit,
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Remember your password?',
                style: TextStyle(color: textPrimary),
              ),
              CustomTextButtonWidget(
                title: 'Login',
                onTap: () {
                  context.go(Constants.loginRoute);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
