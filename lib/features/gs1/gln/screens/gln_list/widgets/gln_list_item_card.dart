import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_list/widgets/gln_active_chip.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class GlnListItemCard extends StatelessWidget {
  const GlnListItemCard({
    super.key,
    required this.gln,
    this.isSelected = false,
    required this.onTap,
    required this.onMenuSelected,
  });

  final GLN gln;
  final bool isSelected;
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

        final cityCountry = [
          if (gln.city.isNotEmpty) gln.city,
          if (gln.country.isNotEmpty) gln.country,
        ].join(', ');

        final menuIconColor =
            Gs1ListItemSelectionStyle.mutedColor(isSelected, muted);

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
                          gln.locationName,
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
                        infoRow(
                          AppAssets.iconMapPin,
                          '${GlnUiConstants.listCardGlnPrefix}${gln.glnCode}',
                        ),
                        if (gln.addressLine1.isNotEmpty)
                          infoRow(AppAssets.iconMapPin, gln.addressLine1),
                        if (cityCountry.isNotEmpty)
                          infoRow(AppAssets.iconMapPin, cityCountry),
                        if (gln.contactEmail?.isNotEmpty == true)
                          infoRow(AppAssets.iconMail, gln.contactEmail!),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
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
                      PopupMenuButton<String>(
                        tooltip: GlnUiConstants.menuTooltipActions,
                        padding: EdgeInsets.zero,
                        icon: TraqIcon(AppAssets.iconMoreVert, color: menuIconColor),
                        onSelected: onMenuSelected,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                TraqIcon(AppAssets.iconEye, size: 20),
                                const SizedBox(width: 8),
                                Text(GlnUiConstants.menuViewDetails),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                TraqIcon(AppAssets.iconEdit, size: 20),
                                const SizedBox(width: 8),
                                Text(GlnUiConstants.menuEdit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                TraqIcon(AppAssets.iconTrash,
                                  size: 20,
                                  color: Colors.red,
                                ),
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
          