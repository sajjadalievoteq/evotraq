import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_active_chip.dart';

/// List row card matching [GtinListItemCard] layout for GLN master data.
class GlnListItemCard extends StatelessWidget {
  const GlnListItemCard({
    super.key,
    required this.gln,
    required this.onTap,
    required this.onMenuSelected,
  });

  final GLN gln;
  final VoidCallback onTap;

  /// Called with `view`, `edit`, or `delete` when the row overflow menu is used.
  final ValueChanged<String> onMenuSelected;

  String _locationTypeLabel(LocationType type) {
    return type.toString().split('.').last.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
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

        final cityCountry = [
          if (gln.city.isNotEmpty) gln.city,
          if (gln.country.isNotEmpty) gln.country,
        ].join(', ');

        return Card(
          elevation: 2,
          child: ListTile(
            contentPadding: contentPadding,
            title: Text(
              gln.locationName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: isCompact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                infoRow(Icons.pin_outlined, 'GLN: ${gln.glnCode}'),
                if (gln.addressLine1.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  infoRow(Icons.place_outlined, gln.addressLine1),
                ],
                if (cityCountry.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  infoRow(Icons.location_city_outlined, cityCountry),
                ],
                if (gln.contactEmail?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  infoRow(Icons.email_outlined, gln.contactEmail!),
                ],
              ],
            ),
            trailing: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isCompact ? 132 : 148),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlnActiveChip(active: gln.active),
                        const SizedBox(height: 2),
                        Text(
                          _locationTypeLabel(gln.locationType),
                          style: TextStyle(fontSize: 10, color: muted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Actions',
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_vert, color: muted),
                    onSelected: onMenuSelected,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
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
