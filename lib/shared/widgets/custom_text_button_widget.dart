
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';
class CustomTextButtonWidget extends StatelessWidget {
  const CustomTextButtonWidget({super.key, required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onTap, child: Text(title,style: TextStyle(color: context.colors.primary),));
  }
}