import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_background_texture.dart';

class CardWithBackgroundWidget extends StatelessWidget {
  const CardWithBackgroundWidget({
    super.key,
    required this.child,
    this.isPrimary = true,
    this.shape,
    this.elevation,
    this.margin,
  });

  final Widget child;
  final bool? isPrimary;
  final ShapeBorder? shape;
  final double? elevation;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: shape,
      elevation: elevation,
      margin: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isPrimary == true
              ? context.colors.primary
              : context.colors.background,
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            const Positioned.fill(
              child: TraqBackgroundTexture(fit: BoxFit.cover),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
