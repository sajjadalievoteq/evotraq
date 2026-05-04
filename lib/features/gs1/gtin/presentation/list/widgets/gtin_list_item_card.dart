import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/widgets/gtin_status_chip.dart';

/// List row card for a single GTIN (master data list).
class GtinListItemCard extends StatelessWidget {
  const GtinListItemCard({
    super.key,
    required this.gtin,
    required this.onTap,
  });

  final GTIN gtin;
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

        Widget infoRow(IconData icon, String text) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(icon, size: 16, color: muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }

        return Card(
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // ✅ FIXED ALIGNMENT
                children: [
                  /// LEFT SIDE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gtin.productName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: isCompact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        infoRow(Icons.qr_code, 'GTIN: ${gtin.gtinCode}'),

                        if (gtin.manufacturer != null)
                          infoRow(
                            Icons.business,
                            '${GtinUiConstants.listCardManufacturerPrefix}${gtin.manufacturer}',
                          ),

                        if (gtin.packagingLevel != null)
                          infoRow(
                            Icons.inventory,
                            '${GtinUiConstants.listCardLevelPrefix}${gtin.packagingLevel}',
                          ),

                        if (gtin.registrationDate != null)
                          infoRow(
                            Icons.calendar_today,
                            '${GtinUiConstants.listCardRegisteredPrefix}'
                                '${DateFormat('MMM dd, yyyy').format(gtin.registrationDate!)}',
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// RIGHT SIDE (TOP ALIGNED LIKE GLN)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GtinStatusChip(status: gtin.status),

                      const SizedBox(height: 6),

                      if (gtin.packSize != null)
                        Text(
                          '${GtinUiConstants.listCardPackPrefix}${gtin.packSize}',
                          style: TextStyle(fontSize: 10, color: muted),
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