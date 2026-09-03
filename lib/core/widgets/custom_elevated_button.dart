import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_buttons.dart';
import 'package:traqtrace_app/core/theme/traq_theme_typography.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.fontSize = 16,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = TraqThemeButtons.fixedHeight(height);

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: c.primary,
              strokeWidth: 2.2,
            ),
          )
        : Text(
            label,
            textHeightBehavior: TraqText.heightBehavior,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.2,
              leadingDistribution: TextLeadingDistribution.even,
              color: Colors.white,
            ),
          );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: isLoading
          ? FilledButton(
              onPressed: null,
              clipBehavior: Clip.none,
              style: style,
              child: child,
            )
          : (isEnabled
                ? FilledButton(
                    onPressed: onPressed,
                    clipBehavior: Clip.none,
                    style: style,
                    child: child,
                  )
                : OutlinedButton(
                    onPressed: null,
                    clipBehavior: Clip.none,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.primary.withOpacity(0.55)),
                      foregroundColor: c.primary.withOpacity(0.75),
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
                  )),
    );
  }
}
