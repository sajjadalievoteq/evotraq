import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/animation/traq_staggered_entrance.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/email_provider_launch_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/features/auth/screens/check_email/widgets/check_email_next_steps_card.dart';
import 'package:traqtrace_app/features/auth/screens/check_email/widgets/check_email_status_icon.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';

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
    final emailText = email?.trim();
    final inboxDestination = resolveEmailInboxDestination(emailText);

    return TraqStaggeredEntrance(
      children: [
        const CheckEmailStatusIcon(),
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
        const CheckEmailNextStepsCard(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: AuthActionButton(
            label: inboxDestination.label,
            onPressed: () => openInboxForEmail(emailText),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: TraqAnimationManager.durationOf(
            context,
            TraqAnimationConstants.swap,
          ),
          curve: TraqAnimationConstants.curve,
          child: SizedBox(
            width: double.infinity,
            child: AuthActionButton(
              label: 'RESEND EMAIL',
              onPressed: onResend,
              isLoading: isResending,
              isEnabled: onResend != null && !isResending,
            ),
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
