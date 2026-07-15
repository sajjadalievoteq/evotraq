import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_list/widgets/gtin_status_chip.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

class GtinListItemCard extends StatelessWidget {
  const GtinListItemCard({
    super.key,
    required this.gtin,
    this.isSelected = false,
    required this.onTap,
  });

  final GTIN gtin;
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

        Widget infoRow(String iconAsset, String text) {
          final rowColor =
              Gs1ListItemSelectionStyle.mutedColor(isSelected, muted);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                TraqIcon(iconAsset, size: 16, color: rowColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: rowColor),
                  ),
                ),
              ],
            ),
          );
        }

        return Card(
          elevation: 2,
          color: Gs1ListItemSelectionStyle.cardBackground(context, isSelected),
          child: InkWell(
            onTap: onTap,
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
                          gtin.productName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Gs1ListItemSelectionStyle.primaryTextColor(
                              isSelected,
                            ),
                          ),
                          maxLines: isCompact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        infoRow(NavIcons.gtin, 'GTIN: ${gtin.gtinCode}'),

                        if (gtin.manufacturer != null)
                          infoRow(
                            AppAssets.iconFactory,
                            '${GtinUiConstants.listCardManufacturerPrefix}${gtin.manufacturer}',
                          ),

                        if (gtin.registrationDate != null)
                          infoRow(
                            AppAssets.iconCalendar,
                            '${GtinUiConstants.listCardRegisteredPrefix}'
                            '${DateFormat('MMM dd, yyyy').format(gtin.registrationDate!)}',
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GtinStatusChip(status: gtin.status),

                      const SizedBox(height: 6),

                      if (gtin.packSize != null)
                        Text(
                          '${GtinUiConstants.listCardPackPrefix}${gtin.packSize}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Gs1ListItemSelectionStyle.mutedColor(
                              isSelected,
                              muted,
                            ),
                          ),
                          textAlign: TextAlign.end,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
