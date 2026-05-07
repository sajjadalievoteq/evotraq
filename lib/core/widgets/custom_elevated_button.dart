import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';

/// Core filled/outlined action button with a fixed height.
/// Keeps layout stable when showing a loading spinner.
class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.height = 50,
    this.fontSize = 16,
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
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: isLoading
          ? FilledButton(onPressed: null, child: child)
          : (isEnabled
              ? FilledButton(onPressed: onPressed, child: child)
              : OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.primary.withOpacity(0.55)),
                    foregroundColor: c.primary.withOpacity(0.75),
                  ),
                  child: Text(label, style: TextStyle(fontSize: fontSize)),
                )),
    );
  }
}

