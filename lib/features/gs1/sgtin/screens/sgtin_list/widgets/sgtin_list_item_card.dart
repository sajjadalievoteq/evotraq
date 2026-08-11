import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_info_row.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_list/widgets/sgtin_status_chip.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class SgtinListItemCard extends StatelessWidget {
  const SgtinListItemCard({
    super.key,
    required this.sgtin,
    this.isSelected = false,
    required this.onTap,
  });

  final SGTIN sgtin;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;

        final padding = isCompact
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
            : const EdgeInsets.all(16);

        return Card(
          color: Gs1ListItemSelectionStyle.cardBackground(context, isSelected),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(2),
            child: Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${SgtinUiConstants.listCardSerialPrefix}${sgtin.serialNumber}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Gs1ListItemSelectionStyle.primaryTextColor(
                              isSelected,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Gs1ListItemInfoRow(
                          AppAssets.iconQr,
                          '${SgtinUiConstants.listCardGtinPrefix}${sgtin.gtinCode}',

                          isSelected: isSelected,
                          muted: muted,
                          iconSize: 14,
                          textStyle: theme.textTheme.bodySmall,
                        ),
                        if (sgtin.batchLotNumber != null)
                          Gs1ListItemInfoRow(
                            AppAssets.iconTag,
                            '${SgtinUiConstants.listCardBatchPrefix}${sgtin.batchLotNumber}',

                            isSelected: isSelected,
                            muted: muted,
                            iconSize: 14,
                            textStyle: theme.textTheme.bodySmall,
                          ),
                        if (sgtin.expiryDate != null)
                          Gs1ListItemInfoRow(
                            AppAssets.iconCalendar,
                            '${SgtinUiConstants.listCardExpiryPrefix}'
                            '${DateFormat('MMM dd, yyyy').format(sgtin.expiryDate!)}',

                            isSelected: isSelected,
                            muted: muted,
                            iconSize: 14,
                            textStyle: theme.textTheme.bodySmall,
                          ),
                        if (sgtin.currentLocation != null)
                          Gs1ListItemInfoRow(
                            AppAssets.iconMapPin,
                            '${SgtinUiConstants.listCardLocationPrefix}'
                            '${sgtin.currentLocation!.locationName}',

                            isSelected: isSelected,
                            muted: muted,
                            iconSize: 14,
                            textStyle: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SgtinStatusChip(status: sgtin.status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
