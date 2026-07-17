import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_staggered_entrance.dart';

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
    final c = context.colors;
    final primary = c.primary;
    final textSecondary = c.textSecondary;

    return AuthStaggeredEntrance(
      children: [
        const SizedBox(height: 40),
        AuthIconPop(
          child: SvgPicture.asset(
            AppAssets.iconCheck,
            width: 100,
            height: 100,
            colorFilter: ColorFilter.mode(c.success, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 32),
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
          style: TextStyle(fontSize: 16, color: textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        AuthActionButton(label: buttonLabel, onPressed: onButtonPressed),
      ],
    );
  }
}
