import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/color_manager.dart';
import 'auth_action_button.dart';

class VarifyEmailContentWidget extends StatelessWidget {
  const VarifyEmailContentWidget({
    super.key,
    required this.context,
    required bool isVerifying,
    required bool isVerified,
    required String? errorMessage,
  }) : _isVerifying = isVerifying, _isVerified = isVerified, _errorMessage = errorMessage;

  final BuildContext context;
  final bool _isVerifying;
  final bool _isVerified;
  final String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final textPrimary = ColorManager.textPrimary(context);
    final textSecondary = ColorManager.textSecondary(context);

    if (_isVerifying) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Verifying your email...',
            style: TextStyle(fontSize: 18, color: textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_isVerified) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: ColorManager.success(context),
            size: 100,
          ),
          const SizedBox(height: 24),
          Text(
            'Email Verified Successfully!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your email has been verified. Your account is now pending admin approval.',
            style: TextStyle(fontSize: 16, color: textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AuthActionButton(
              label: 'GO TO LOGIN',
              onPressed: () {
                context.go(Constants.loginRoute);
              },
            ),
          ),
        ],
      );
    }

    // Error state
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: ColorManager.error(context),
          size: 100,
        ),
        const SizedBox(height: 24),
        Text(
          'Verification Failed',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          _errorMessage ?? 'An error occurred during email verification.',
          style: TextStyle(fontSize: 16, color: textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: AuthActionButton(
            label: 'GO TO LOGIN',
            onPressed: () {
              context.go(Constants.loginRoute);
            },
          ),
        ),
      ],
    );
  }
}