import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_action_button.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';

import 'package:traqtrace_app/core/utils/email_provider_launch_utils.dart';

class CheckEmailContentWidget extends StatelessWidget {
  const CheckEmailContentWidget({
    super.key,
    this.email,
    this.isResending = false,
    this.onResend,
  });

  final String? email;
  final bool isResending;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textPrimary = c.textPrimary;
    final textSecondary = c.textSecondary;
    final primary = c.primary;
    final emailText = email?.trim();
    final inboxDestination = resolveEmailInboxDestination(emailText);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: primary.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.12,
            ),
            borderRadius: BorderRadius.circular(TraqRadius.lg.x),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.iconMail,
              width: 48,
              height: 48,
              colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Verify your email',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          emailText == null || emailText.isEmpty
              ? 'We sent a verification email to your inbox. Please check your inbox and spam folder, then verify your email before logging in.'
              : 'We sent a verification email to $emailText. Please check your inbox and spam folder, then verify your email before logging in.',
          style: TextStyle(fontSize: 16, color: textSecondary, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TraqRadius.md.x),
            border: Border.all(
              color: primary.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.25,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What happens next?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '1. Open the verification email.\n2. Click the verification link.\n3. Return here and log in.\n4. If your email is verified, your account may still wait for admin approval.',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: AuthActionButton(
            label: inboxDestination.label,
            onPressed: () => openInboxForEmail(emailText),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: AuthActionButton(
            label: 'RESEND EMAIL',
            onPressed: onResend,
            isLoading: isResending,
            isEnabled: onResend != null && !isResending,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomOutlinedButtonWidget(
            title: 'BACK TO LOGIN',
            onTap: () => context.go(Constants.loginRoute),
          ),
        ),
      ],
    );
  }
}
