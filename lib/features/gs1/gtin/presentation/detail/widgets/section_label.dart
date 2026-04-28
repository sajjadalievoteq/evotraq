import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(top: 16, bottom: 12),
  });

  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

