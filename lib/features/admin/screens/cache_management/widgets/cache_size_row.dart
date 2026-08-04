import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CacheSizeRow extends StatelessWidget {
  const CacheSizeRow(
    this.type,
    this.entries,
    this.iconAsset,
    this.color, {
    super.key,
  });

  final String type;
  final int entries;
  final String iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TraqIcon(iconAsset, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(type, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$entries entries',
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          entries > 0 ? 'Active' : 'Empty',
          style: TextStyle(
            color: entries > 0
                ? AppColorMapper.successColor(context)
                : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
