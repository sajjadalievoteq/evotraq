import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';

/// A custom loading indicator with the app's primary color
class LoadingIndicator extends StatelessWidget {
  /// Size of the loading indicator
  final double size;

  /// Stroke width of the circular progress indicator
  final double strokeWidth;

  /// Creates a new LoadingIndicator instance
  const LoadingIndicator({
    Key? key,
    this.size = 40,
    this.strokeWidth = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );
  }
}