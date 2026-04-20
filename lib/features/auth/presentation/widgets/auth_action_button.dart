import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';

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
    final primary = ColorManager.primary(context);

    return SizedBox(
      height: height,
      child: isLoading || isEnabled
          ? ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.2,
          ),
        )
            : Text(label, style: TextStyle(fontSize: fontSize)),
      )
          : AbsorbPointer(
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primary.withOpacity(0.55)),
            foregroundColor: primary.withOpacity(0.75),
          ),
          child: Text(label, style: TextStyle(fontSize: fontSize)),
        ),
      ),
    );
  }
}

