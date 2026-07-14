import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_status_rules.dart' as status_rules;
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_navigation.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class CommissioningDetailSerialItemRow extends StatelessWidget {
  const CommissioningDetailSerialItemRow({
    super.key,
    required this.item,
    this.currentStatus,
  });

  final CommissioningBatchItem item;
  final ItemStatus? currentStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          TraqIcon(
            item.success ? AppAssets.iconCheck : AppAssets.iconX,
            size: 16,
            color: item.success ? Colors.green[600] : Colors.red[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.serialNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.canonicalIdentifier != null)
                  Text(
                    item.canonicalIdentifier!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (!item.success && item.errorMessage != null)
                  Text(
                    item.errorMessage!,
                    style: TextStyle(fontSize: 11, color: Colors.red[600]),
                  ),
              ],
            ),
          ),
          if (item.canonicalIdentifier != null)
            IconButton(
              icon: TraqIcon(AppAssets.iconAggregate, size: 16),
              tooltip: 'View hierarchy',
              visualDensity: VisualDensity.compact,
              onPressed: () => openHierarchyScreen(
                context,
                epc: item.canonicalIdentifier!,
                title: 'Commissioning Hierarchy',
              ),
            ),
          if (currentStatus != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Chip(
                label: Text(
                  status_rules.friendlyLabel(currentStatus!),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: status_rules.statusColor(currentStatus!),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: item.serialNumber));
              context.showSuccess(
                'Copied: \${item.serialNumber}',
                duration: const Duration(seconds: 2),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: TraqIcon(AppAssets.iconCopy, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
