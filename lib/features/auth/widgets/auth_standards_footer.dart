import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';

class AuthStandardsFooter extends StatelessWidget {
  const AuthStandardsFooter({
    super.key,
    required this.muted,
    required this.style,
  });

  final Color muted;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('GS1 EPCIS 2.0', style: style),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TraqSpacing.sm),
          child: Container(
            height: 3,
            width: 3,
            decoration: BoxDecoration(color: muted, shape: BoxShape.circle),
          ),
        ),
        Text('CBV 2.0', style: style),
      ],
    );
  }
}
