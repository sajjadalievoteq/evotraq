import 'package:traqtrace_app/core/animation/traq_status_switcher.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/email_provider_launch_utils.dart';
import 'package:traqtrace_app/core/web/auth_navigation_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/auth_navigation_web.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/features/auth/screens/verify_email/utils/verify_email_status_utils.dart';
import 'package:traqtrace_app/features/auth/screens/verify_email/widgets/verify_email_approval_note.dart';
import 'package:traqtrace_app/features/auth/screens/verify_email/widgets/verify_email_status_icon.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class VerifyEmailContentWidget extends StatelessWidget {
  const VerifyEmailContentWidget({
    super.key,
    required this.isVerifying,
    required this.successMessage,
    required this.errorMessage,
    this.email,
  });

  final bool isVerifying;
  final String? successMessage;
  final String? errorMessage;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textPrimary = c.textPrimary;
    final textSecondary = c.textSecondary;
    final inboxDestination = resolveEmailInboxDestination(email);

    return TraqStatusSwitcher(
      statusKey: VerifyEmailStatusUtils.statusKey(
        isVerifying: isVerifying,
        successMessage: successMessage,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VerifyEmailStatusIcon(
            isVerifying: isVerifying,
            isSuccess: successMessage != null,
          ),
          const SizedBox(height: 24),
          Text(
            isVerifying
                ? 'Verifying your email...'
                : (successMessage != null
                      ? 'Email verified'
                      : 'Verification failed'),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isVerifying
                ? 'Please wait while we verify your email address.'
                : (successMessage ??
                      errorMessage ??
                      'An error occurred during email verification.'),
            style: TextStyle(fontSize: 16, color: textSecondary, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (successMessage != null) const VerifyEmailApprovalNote(),
          if (!isVerifying) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AuthActionButton(
                label: successMessage != null
                    ? 'GO TO LOGIN'
                    : inboxDestination.label,
                onPressed: successMessage != null
                    ? () => goToLogin(context)
                    : () => openInboxForEmail(email),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomOutlinedButtonWidget(
                title: 'BACK TO LOGIN',
                onTap: () => goToLogin(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
