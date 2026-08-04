import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class CheckEmailNextStepsCard extends StatelessWidget {
  const CheckEmailNextStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textPrimary = c.textPrimary;
    final textSecondary = c.textSecondary;
    final primary = c.primary;

    return Container(
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
    );
  }
}
