import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ProductHierarchyRecentParentRowLine extends StatelessWidget {
  const ProductHierarchyRecentParentRowLine({
    required this.iconAsset,
    required this.text,
    required this.color,
  });

  final String iconAsset;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TraqIcon(iconAsset, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}
