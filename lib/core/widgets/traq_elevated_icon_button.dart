import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class TraqElevatedIconButton extends StatelessWidget {
  const TraqElevatedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.gap = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.minimumSize = const Size(0, TraqSpacing.buttonH),
    this.style,
    this.labelStyle,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final double gap;
  final EdgeInsetsGeometry padding;
  final Size minimumSize;
  final ButtonStyle? style;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final text = labelStyle != null
        ? Text(label, style: labelStyle)
        : Text(label);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding,
        minimumSize: minimumSize,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
      ).merge(style),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: gap),
          text,
        ],
      ),
    );
  }
}
