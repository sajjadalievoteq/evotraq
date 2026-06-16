import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class CustomOutlinedButtonWidget extends StatelessWidget {
  const CustomOutlinedButtonWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.height = TraqSpacing.buttonH,
  });

  final String title;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, height),
      ),
      child: Text(title),
    );
  }
}
