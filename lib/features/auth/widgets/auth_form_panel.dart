import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_staggered_entrance.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_surface_card.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

/// Auth card chrome: title lines stagger in, then the card fades into focus.
/// Field-level stagger lives inside each form widget.
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
    final titleSize = compactHeader ? 32.0 : 26.0;
    final bodySize = compactHeader ? 14.0 : 12.0;
    final eyebrowSize = compactHeader ? 13.0 : 12.0;
    final gapAfterHeader = compactHeader ? 20.0 : 40.0;

    final surface = wrapInCard ? AuthSurfaceCard(child: child) : child;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TraqStaggeredEntrance(
          children: [
            Text(
              header.eyebrow,
              style: t.body.copyWith(
                color: c.textMuted,
                fontSize: eyebrowSize,
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              header.title,
              style: t.body.copyWith(
                color: c.textPrimary,
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              header.subtitle,
              style: t.body.copyWith(
                color: c.textMuted,
                fontSize: bodySize,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        SizedBox(height: gapAfterHeader),
        TraqFadeScaleEntrance(child: surface),
      ],
    );
  }
}
