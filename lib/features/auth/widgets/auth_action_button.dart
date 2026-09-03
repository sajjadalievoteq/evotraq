import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/animation/traq_fade_scale_transition.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_buttons.dart';
import 'package:traqtrace_app/core/theme/traq_theme_typography.dart';

class AuthActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double height;
  final double fontSize;

  const AuthActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.height = 50,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduce = TraqAnimationManager.reduceMotion(context);
    final duration = TraqAnimationManager.durationOf(
      context,
      TraqAnimationConstants.fastDuration,
    );

    final loadingChild = SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(color: colors.primary, strokeWidth: 2.2),
    );

    final style = TraqThemeButtons.fixedHeight(height);

    final labelChild = Text(
      label,
      textHeightBehavior: TraqText.heightBehavior,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.2,
        leadingDistribution: TextLeadingDistribution.even,
        color: Colors.white,
      ),
    );

    final button = isLoading
        ? FilledButton(
            onPressed: null,
            clipBehavior: Clip.none,
            style: style,
            child: loadingChild,
          )
        : (isEnabled
              ? FilledButton(
                  onPressed: onPressed,
                  clipBehavior: Clip.none,
                  style: style,
                  child: labelChild,
                )
              : OutlinedButton(
                  onPressed: null,
                  clipBehavior: Clip.none,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.primary.withOpacity(0.55)),
                    foregroundColor: colors.primary.withOpacity(0.75),
                  ).merge(style),
                  child: Text(
                    label,
                    textHeightBehavior: TraqText.heightBehavior,
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.2,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                ));

    return SizedBox(
      width: double.infinity,
      height: height,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: TraqAnimationConstants.curve,
        switchOutCurve: TraqAnimationConstants.reverseCurve,
        transitionBuilder: (child, animation) {
          if (reduce) return child;
          return TraqFadeScaleTransition(
            child: child,
            animation: animation,
            beginScale: TraqAnimationConstants.buttonInitialScale,
            alignment: Alignment.center,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(
            isLoading ? 'loading' : (isEnabled ? 'enabled' : 'disabled'),
          ),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: button,
          ),
        ),
      ),
    );
  }
}
