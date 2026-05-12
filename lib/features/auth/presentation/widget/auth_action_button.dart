import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:world_countries/helpers.dart';

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

    final loadingChild = SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(color: colors.primary, strokeWidth: 2.2),
    );

    final labelChild = Text(
      label,
      style: TextStyle(fontSize: fontSize, color: Colors.white),
    );

    return SizedBox(
      height: height,
      child: isLoading
          ? FilledButton(onPressed: null, child: loadingChild)
          : (isEnabled
                ? FilledButton(onPressed: onPressed, child: labelChild)
                : OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.primary.withOpacity(0.55)),
                      foregroundColor: colors.primary.withOpacity(0.75),
                    ),
                    child: Text(label, style: TextStyle(fontSize: fontSize)),
                  )),
    );
  }
}
