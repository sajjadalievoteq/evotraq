import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:traqtrace_app/shared/utils/email_provider_launch_utils.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';

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
    final textPrimary = ColorManager.textPrimary(context);
    final textSecondary = ColorManager.textSecondary(context);
    final primary = ColorManager.primary(context);
    final success = ColorManager.success(context);
    final error = ColorManager.error(context);
    final inboxDestination = resolveEmailInboxDestination(email);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: isVerifying
                ? ColorManager.primaryContainer(context)
                : (successMessage != null
                      ? success.withValues(alpha: 0.14)
                      : error.withValues(alpha: 0.14)),
            borderRadius: BorderRadius.circular(28),
          ),
          child: isVerifying
              ? Padding(
                  padding: const EdgeInsets.all(28),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      primary,
                    ),
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
          style: TextStyle(
            fontSize: 16,
            color: textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (successMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
        
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorManager.primaryBorder(context),
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
                  ? () => context.go(Constants.loginRoute)
                  : () => openInboxForEmail(email),
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
      ],
    );
  }
}
