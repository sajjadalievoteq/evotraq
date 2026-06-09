import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;

  final double strokeWidth;

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
        valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
      ),
    );
  }
}