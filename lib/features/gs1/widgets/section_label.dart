import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(top: 16, bottom: 12),
    this.fontWeight = FontWeight.w700,
  });

  final String text;
  final EdgeInsets padding;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final String capitalizedText = text.isEmpty 
        ? text 
        : text[0].toUpperCase() + text.substring(1);

    return Padding(
      padding: padding,
      child: Text(
        capitalizedText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: fontWeight,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
