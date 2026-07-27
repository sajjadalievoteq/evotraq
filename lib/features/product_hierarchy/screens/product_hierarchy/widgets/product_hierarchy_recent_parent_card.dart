import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_identifier_utils.dart';

class ProductHierarchyRecentParentCard extends StatelessWidget {
  const ProductHierarchyRecentParentCard({
    super.key,
    required this.operation,
    required this.onTap,
  });

  final PackingResponse operation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final titleColor = Gs1ListItemSelectionStyle.primaryTextColor(false);
    final rowColor = Gs1ListItemSelectionStyle.mutedColor(false, muted);

    final parent = normalizeProductHierarchyInput(
      operation.parentContainerId ?? '',
    );
    final ssccLabel = _ssccDisplay(parent);
    final count = operation.packedItemsCount ?? 0;
    final statusLabel = switch (operation.status) {
      OperationStatus.success => 'Success',
      OperationStatus.partialSuccess => 'Partial success',
      OperationStatus.failed => 'Failed',
      OperationStatus.validationError => 'Validation error',
      OperationStatus.accepted => 'Accepted',
      null => null,
    };
    final packedAt = operation.processedAt;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SSCC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$count item${count == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: rowColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TraqIcon(NavIcons.sscc, size: 20, color: titleColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ssccLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (statusLabel != null) ...[
                _RowLine(
                  iconAsset: NavIcons.productHierarchy,
                  text: statusLabel,
                  color: rowColor,
                ),
                const SizedBox(height: 4),
              ],
              if (packedAt != null)
                _RowLine(
                  iconAsset: AppAssets.iconCalendar,
                  text: DateFormat('MMM dd, yyyy HH:mm').format(packedAt),
                  color: rowColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _ssccDisplay(String epc) {
    if (epc.isEmpty) return 'Unknown container';
    final digits = RegExp(r'(\d{18})').firstMatch(epc)?.group(1);
    if (digits != null) return digits;
    if (epc.length <= 24) return epc;
    return '…${epc.substring(epc.length - 18)}';
  }
}

class _RowLine extends StatelessWidget {
  const _RowLine({
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
