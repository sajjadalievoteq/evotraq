import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';

class OperationCardFooter extends StatelessWidget {
  const OperationCardFooter({
    super.key,
    required this.operation,
    required this.isSelected,
    required this.rowColor,
  });
  final Operation operation;
  final bool isSelected;
  final Color rowColor;

  @override
  Widget build(BuildContext context) {
    if (operation.operationType == OperationType.commissioning) {
      final commissioned = operation.totalCommissioned ?? operation.itemCount;
      final failed = operation.totalFailedCount ?? 0;
      final failureColor = AppColorMapper.operationStatusColor(
        context,
        OperationStatus.failed,
      );
      return Row(
        children: [
          TraqIcon(AppAssets.iconCheck, size: 14, color: rowColor),
          const SizedBox(width: 4),
          Text(
            '$commissioned commissioned',
            style: TextStyle(color: rowColor, fontSize: 12),
          ),
          if (failed > 0) ...[
            const SizedBox(width: 12),
            TraqIcon(AppAssets.iconAlert, size: 14, color: failureColor),
            const SizedBox(width: 4),
            Text(
              '$failed failed',
              style: TextStyle(color: failureColor, fontSize: 12),
            ),
          ],
        ],
      );
    }
    return Text(
      '${operation.eventIds?.length ?? 0} events',
      style: TextStyle(color: rowColor, fontSize: 12),
    );
  }
}
