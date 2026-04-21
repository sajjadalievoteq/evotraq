
import 'package:flutter/material.dart';
class CustomTextButtonWidget extends StatelessWidget {
  const CustomTextButtonWidget({super.key, required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onTap, child: Text(title));
  }
}