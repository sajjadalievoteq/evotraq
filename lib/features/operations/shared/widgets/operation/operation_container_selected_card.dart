import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';

class OperationContainerSelectedCard extends StatelessWidget {
  const OperationContainerSelectedCard({
    super.key,
    required this.containerId,
    required this.onClear,
  });

  final String containerId;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final color =
        AppColorMapper.operationTypeColor(context, OperationType.packing);
    return Card(
      color: AppColorMapper.operationTypeSoft(context, OperationType.packing),
      child: ListTile(
        leading: TraqIcon(AppColorMapper.operationTypeIcon(OperationType.packing),
            color: color),
        title: const Text('Container Selected'),
        subtitle: Text(
          containerId,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: IconButton(
          icon: TraqIcon(AppAssets.iconX),
          onPressed: onClear,
        ),
      ),
    );
  }
}
