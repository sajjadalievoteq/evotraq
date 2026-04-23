import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
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
        final horizontalMargin = isCompact ? 8.0 : 16.0;
        final contentPadding = isCompact
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
            : const EdgeInsets.all(16);

        Widget infoRow(IconData icon, String text) {
          return Row(
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
          );
        }

        return Card(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 4),
          elevation: 2,
          child: ListTile(
            contentPadding: contentPadding,
            title: Text(
              gtin.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: isCompact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                infoRow(Icons.qr_code, 'GTIN: ${gtin.gtinCode}'),
                if (gtin.manufacturer != null) ...[
                  const SizedBox(height: 4),
                  infoRow(Icons.business, 'Manufacturer: ${gtin.manufacturer}'),
                ],
                if (gtin.packagingLevel != null) ...[
                  const SizedBox(height: 4),
                  infoRow(Icons.inventory, 'Level: ${gtin.packagingLevel}'),
                ],
                if (gtin.registrationDate != null) ...[
                  const SizedBox(height: 4),
                  infoRow(
                    Icons.calendar_today,
                    'Registered: ${DateFormat('MMM dd, yyyy').format(gtin.registrationDate!)}',
                  ),
                ],
              ],
            ),
            trailing: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isCompact ? 90 : 110),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GtinStatusChip(status: gtin.status),
                  if (gtin.packSize != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Pack: ${gtin.packSize}',
                      style: TextStyle(fontSize: 10, color: muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }
}

