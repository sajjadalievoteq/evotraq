import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/web/auth_navigation_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/auth_navigation_web.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_staggered_entrance.dart';
import 'package:traqtrace_app/core/utils/email_provider_launch_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';

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

  String get _statusKey {
    if (isVerifying) return 'verifying';
    if (successMessage != null) return 'success';
    return 'error';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textPrimary = c.textPrimary;
    final textSecondary = c.textSecondary;
    final primary = c.primary;
    final success = c.success;
    final error = c.error;
    final inboxDestination = resolveEmailInboxDestination(email);

    return AuthStatusSwitcher(
      statusKey: _statusKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthIconPop(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isVerifying
                    ? primary.withOpacity(
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.22
                            : 0.12,
                      )
                    : (successMessage != null
                          ? success.withValues(alpha: 0.14)
                          : error.withValues(alpha: 0.14)),
                borderRadius: BorderRadius.circular(TraqRadius.lg.x),
              ),
              child: isVerifying
                  ? Padding(
                      padding: const EdgeInsets.all(28),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ),
                    )
                  : Center(
                      child: SvgPicture.asset(
                        successMessage != null
                            ? AppAssets.iconCheck
                            : AppAssets.iconMail,
                        width: 48,
                        height: 48,
                        colorFilter: ColorFilter.mode(
                          successMessage != null ? success : error,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
            ),
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
          if (successMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TraqRadius.md.x),
                border: Border.all(
                  color: primary.withOpacity(
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.35
                        : 0.25,
                  ),
                ),
              ),
              child: Text(
                'You can now return to login. If your email is verified but your account is still not accessible, it may still be waiting for admin approval.',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
