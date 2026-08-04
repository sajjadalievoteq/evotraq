import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

/// Shared prompt + text-button row used on auth forms (login / register links).
class AuthFooterLinkRow extends StatelessWidget {
  const AuthFooterLinkRow({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          prompt,
          style: context.text.body.copyWith(color: c.textPrimary),
        ),
        CustomTextButtonWidget(
          title: actionLabel,
          onTap: onTap,
        ),
      ],
    );
  }
}
