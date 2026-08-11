import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_card_row.dart';

class OperationCardRowLine extends StatelessWidget {
  const OperationCardRowLine({
    super.key,
    required this.row,
    required this.color,
  });
  final OperationCardRow row;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TraqIcon(row.iconAsset, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            row.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}
