import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

/// Core filled/outlined action button with a fixed height.
/// Keeps layout stable when showing a loading spinner.
class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,

    this.fontSize = 16,  this.height=50,
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
      width: double.infinity,
      child: isLoading
          ? FilledButton(onPressed: null, child: Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
            child: child,
          )))
          : (isEnabled
              ? FilledButton(onPressed: onPressed, child: Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
                child: child,
              )))
              : OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.primary.withOpacity(0.55)),
                    foregroundColor: c.primary.withOpacity(0.75),
                  ),
                  child: Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(label, style: TextStyle(fontSize: fontSize)),
                  )),
                )),
    );
  }
}

