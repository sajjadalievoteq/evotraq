import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_responsive_layout_widget.dart';

import '../../../../../core/config/constants.dart';

class ResetPasswordInvalidTokenWidget extends StatelessWidget {
  const ResetPasswordInvalidTokenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textPrimary = c.textPrimary;
    final textSecondary = c.textSecondary;

    return AuthResponsiveFormLayout(
      header: AuthFormHeader.invalidResetLink,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppAssets.iconAlert,
            width: 80,
            height: 80,
            colorFilter: ColorFilter.mode(c.error, BlendMode.srcIn),
          ),
          const SizedBox(height: 24),
          Text(
            'Invalid or Expired Link',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'The password reset link you used is invalid or has expired. Please request a new password reset link.',
            style: TextStyle(fontSize: 16, color: textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AuthActionButton(
              label: 'REQUEST NEW LINK',
              onPressed: () {
                context.go(Constants.forgotPasswordRoute);
              },
            ),
          ),
        ],
      ),
    );
  }
}
