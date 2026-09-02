import 'package:traqtrace_app/core/animation/traq_fade_scale_entrance.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_surface_card.dart';

class AuthFormPanel extends StatelessWidget {
  const AuthFormPanel({
    super.key,
    required this.header,
    required this.child,
    this.wrapInCard = true,
    this.compactHeader = false,
  });

  final AuthFormHeader header;
  final Widget child;
  final bool wrapInCard;
  final bool compactHeader;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final titleSize = compactHeader ? 24.0 : 26.0;
    final bodySize = compactHeader ? 13.0 : 12.0;
    final gapAfterHeader = compactHeader ? TraqSpacing.lg : 40.0;

    final surface = wrapInCard ? AuthSurfaceCard(child: child) : child;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          header.eyebrow,
          style: t.body.copyWith(color: c.textMuted, fontSize: 12),
          textAlign: TextAlign.left,
        ),
        if (compactHeader) const SizedBox(height: TraqSpacing.xs),
        Text(
          header.title,
          style: t.body.copyWith(
            color: c.textPrimary,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (compactHeader) const SizedBox(height: TraqSpacing.xs),
        Text(
          header.subtitle,
          style: t.body.copyWith(color: c.textMuted, fontSize: bodySize),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: gapAfterHeader),
        TraqFadeScaleEntrance(child: surface),
      ],
    );
  }
}
