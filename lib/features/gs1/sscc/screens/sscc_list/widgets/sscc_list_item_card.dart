import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';

import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_list/widgets/sscc_status_chip.dart';

import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';

import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart'
    as edit_rules;
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

class SsccListItemCard extends StatelessWidget {
  const SsccListItemCard({
    super.key,
    required this.sscc,
    this.isSelected = false,
    required this.onTap,
    required this.onMenuSelected,
  });

  final SSCC sscc;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;

  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final muted = theme.colorScheme.onSurfaceVariant;

    final dateFormat = DateFormat('MMM dd, yyyy');
    final canEdit = edit_rules.canEditSsccRecord(sscc.status);
    final canDelete = edit_rules.canDeleteSscc(sscc.status);

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

    return LayoutBuilder(

      builder: (context, constraints) {

        final isCompact = constraints.maxWidth < 420;

        final padding = isCompact

            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)

            : const EdgeInsets.all(16);

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
                          sscc.ssccCode,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Gs1ListItemSelectionStyle.primaryTextColor(
                              isSelected,
                            ),
                          ),

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                        ),

                        const SizedBox(height: 8),

                        infoRow(
                          AppAssets.iconBox,
                          '${SsccUiConstants.listCardTypePrefix}${status_rules.friendlyUnitTypeLabel(sscc.unitType)}',
                        ),

                        if (sscc.issuingGLN?.glnCode != null)
                          infoRow(
                            NavIcons.gln,
                            '${SsccUiConstants.listCardIssuingGlnPrefix}${sscc.issuingGLN!.glnCode}',
                          ),

                        if (sscc.sourceLocation?.locationName.isNotEmpty == true)
                          infoRow(
                            AppAssets.iconMapPin,
                            '${SsccUiConstants.listCardFromPrefix}${sscc.sourceLocation!.locationName}',
                          ),

                        if (sscc.destinationLocation?.locationName.isNotEmpty ==
                            true)
                          infoRow(
                            AppAssets.iconMapPin,
                            '${SsccUiConstants.listCardToPrefix}${sscc.destinationLocation!.locationName}',
                          ),

                        if (sscc.shippingDate != null)
                          infoRow(
                            NavIcons.shipping,
                            '${SsccUiConstants.listCardShippedPrefix}${dateFormat.format(sscc.shippingDate!)}',
                          ),

                      ],

                    ),

                  ),

                  const SizedBox(width: 12),

                  Column(

                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [

                      SsccStatusChip(status: sscc.status),

                      const SizedBox(height: 6),

                      PopupMenuButton<String>(

                        tooltip: SsccUiConstants.menuTooltipActions,

                        padding: EdgeInsets.zero,

                        icon: TraqIcon(AppAssets.iconMoreVert, color: Gs1ListItemSelectionStyle.mutedColor(
                            isSelected,
                            muted,
                          )),

                        onSelected: onMenuSelected,

                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                TraqIcon(AppAssets.iconEye, size: 20),
                                const SizedBox(width: 8),
                                Text(SsccUiConstants.menuViewDetails),
                              ],
                            ),
                          ),
                          if (canEdit)
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  TraqIcon(AppAssets.iconEdit, size: 20),
                                  const SizedBox(width: 8),
                                  Text(SsccUiConstants.menuEdit),
                                ],
                              ),
                            ),
                          if (canDelete)
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
                                    SsccUiConstants.menuDelete,
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