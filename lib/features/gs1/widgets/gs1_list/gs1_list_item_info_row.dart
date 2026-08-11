import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';

class Gs1ListItemInfoRow extends StatelessWidget {
  const Gs1ListItemInfoRow(
    this.iconAsset,
    this.text, {
    super.key,
    required this.isSelected,
    required this.muted,
    this.iconSize = 16,
    this.fontSize,
    this.textStyle,
  });

  final String iconAsset;
  final String text;
  final bool isSelected;
  final Color muted;
  final double iconSize;
  final double? fontSize;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final color = Gs1ListItemSelectionStyle.mutedColor(isSelected, muted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          TraqIcon(iconAsset, size: iconSize, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  textStyle?.copyWith(color: color) ??
                  TextStyle(color: color, fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }
}
