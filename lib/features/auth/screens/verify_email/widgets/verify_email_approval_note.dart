import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';

class VerifyEmailApprovalNote extends StatelessWidget {
  const VerifyEmailApprovalNote({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textSecondary = c.textSecondary;
    final primary = c.primary;

    return Container(
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
    );
  }
}
