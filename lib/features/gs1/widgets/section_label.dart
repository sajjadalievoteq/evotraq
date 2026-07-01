import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(top: 16, bottom: 12),
    this.fontWeight = FontWeight.w700,
    this.showStar = false,
  });

  final String text;
  final EdgeInsets padding;
  final FontWeight fontWeight;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String capitalizedText = text.isEmpty
        ? text
        : text[0].toUpperCase() + text.substring(1);

    final labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: fontWeight,
      color: theme.colorScheme.primary,
    );

    return Padding(
      padding: padding,
      child: showStar
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(capitalizedText, style: labelStyle),
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: labelStyle.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 18,
                  ),
                ),
              ],
            )
          : Text(capitalizedText, style: labelStyle),
    );
  }
}
