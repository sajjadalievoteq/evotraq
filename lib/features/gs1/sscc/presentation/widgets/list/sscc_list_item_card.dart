import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';

import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/list/sscc_status_chip.dart';

import 'package:traqtrace_app/features/gs1/sscc/presentation/utilities/sscc_ui_constants.dart';

import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart'
    as edit_rules;
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;



class SsccListItemCard extends StatelessWidget {

  const SsccListItemCard({

    super.key,

    required this.sscc,

    required this.onTap,

    required this.onMenuSelected,

  });



  final SSCC sscc;

  final VoidCallback onTap;

  final ValueChanged<String> onMenuSelected;



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final muted = theme.colorScheme.onSurfaceVariant;

    final dateFormat = DateFormat('MMM dd, yyyy');
    final canEdit = edit_rules.canEditSsccRecord(sscc.status);
    final canDelete = edit_rules.canDeleteSscc(sscc.status);



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



    return LayoutBuilder(

      builder: (context, constraints) {

        final isCompact = constraints.maxWidth < 420;

        final padding = isCompact

            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)

            : const EdgeInsets.all(16);



        return Card(

          elevation: 2,

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

                          ),

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                        ),

                        const SizedBox(height: 8),

                        infoRow(

                          Icons.inventory_2_outlined,

                          '${SsccUiConstants.listCardTypePrefix}${status_rules.friendlyUnitTypeLabel(sscc.unitType)}',

                        ),

                        if (sscc.issuingGLN?.glnCode != null)

                          infoRow(

                            Icons.factory_outlined,

                            '${SsccUiConstants.listCardIssuingGlnPrefix}${sscc.issuingGLN!.glnCode}',

                          ),

                        if (sscc.sourceLocation?.locationName?.isNotEmpty == true)

                          infoRow(

                            Icons.location_on_outlined,

                            '${SsccUiConstants.listCardFromPrefix}${sscc.sourceLocation!.locationName}',

                          ),

                        if (sscc.destinationLocation?.locationName?.isNotEmpty ==

                            true)

                          infoRow(

                            Icons.location_on,

                            '${SsccUiConstants.listCardToPrefix}${sscc.destinationLocation!.locationName}',

                          ),

                        if (sscc.shippingDate != null)

                          infoRow(

                            Icons.local_shipping_outlined,

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

                        icon: Icon(Icons.more_vert, color: muted),

                        onSelected: onMenuSelected,

                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                const Icon(Icons.visibility, size: 20),
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
                                  const Icon(Icons.edit, size: 20),
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
                                  const Icon(
                                    Icons.delete,
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


