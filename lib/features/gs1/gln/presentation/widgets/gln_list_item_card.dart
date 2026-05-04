import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_active_chip.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';

import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_active_chip.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';

/// List row card matching GTIN layout style for GLN master data.
class GlnListItemCard extends StatelessWidget {
  const GlnListItemCard({
    super.key,
    required this.gln,
    required this.onTap,
    required this.onMenuSelected,
  });

  final GLN gln;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;

  String _locationTypeLabel(LocationType type) {
    return type.toString().split('.').last.replaceAll('_', ' ');
  }

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

        final cityCountry = [
          if (gln.city.isNotEmpty) gln.city,
          if (gln.country.isNotEmpty) gln.country,
        ].join(', ');

        return Card(
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // 👈 TOP ALIGN FIX
                children: [
                  /// LEFT SIDE (CONTENT)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gln.locationName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: isCompact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        infoRow(
                          Icons.pin_outlined,
                          '${GlnUiConstants.listCardGlnPrefix}${gln.glnCode}',
                        ),

                        if (gln.addressLine1.isNotEmpty)
                          infoRow(Icons.place_outlined, gln.addressLine1),

                        if (cityCountry.isNotEmpty)
                          infoRow(Icons.location_city_outlined, cityCountry),

                        if (gln.contactEmail?.isNotEmpty == true)
                          infoRow(Icons.email_outlined, gln.contactEmail!),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// RIGHT SIDE (ALWAYS TOP ALIGNED)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 8),
                          GlnActiveChip(active: gln.active),
                          const SizedBox(height: 6),

                          Text(
                            _locationTypeLabel(gln.locationType),
                            style: TextStyle(fontSize: 10, color: muted),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        tooltip: GlnUiConstants.menuTooltipActions,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_vert, color: muted),
                        onSelected: onMenuSelected,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                const Icon(Icons.visibility, size: 20),
                                const SizedBox(width: 8),
                                Text(GlnUiConstants.menuViewDetails),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text(GlnUiConstants.menuEdit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  GlnUiConstants.menuDelete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
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
