import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/list/widgets/sgtin_status_chip.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/utilities/sgtin_ui_constants.dart';

class SgtinListItemCard extends StatelessWidget {
  const SgtinListItemCard({
    super.key,
    required this.sgtin,
    required this.onTap,
  });

  final SGTIN sgtin;
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
                Icon(icon, size: 14, color: muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ),
              ],
            ),
          );
        }

        return Card(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        infoRow(
                          Icons.qr_code,
                          '${SgtinUiConstants.listCardGtinPrefix}${sgtin.gtinCode}',
                        ),
                        if (sgtin.batchLotNumber != null)
                          infoRow(
                            Icons.batch_prediction,
                            '${SgtinUiConstants.listCardBatchPrefix}${sgtin.batchLotNumber}',
                          ),
                        if (sgtin.expiryDate != null)
                          infoRow(
                            Icons.event,
                            '${SgtinUiConstants.listCardExpiryPrefix}'
                            '${DateFormat('MMM dd, yyyy').format(sgtin.expiryDate!)}',
                          ),
                        if (sgtin.currentLocation != null)
                          infoRow(
                            Icons.location_on,
                            '${SgtinUiConstants.listCardLocationPrefix}'
                            '${sgtin.currentLocation!.locationName}',
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
