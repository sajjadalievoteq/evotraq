import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CommissioningDetailCountBadge extends StatelessWidget {
  const CommissioningDetailCountBadge({
    super.key,
    required this.text,
    required this.color,
    required this.iconAsset,
  });

  final String text;
  final Color color;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TraqIcon(iconAsset, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
