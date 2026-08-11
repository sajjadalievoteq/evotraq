import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_info_row.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/utils/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_detail/widgets/aggregation_event_action_chip.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';

import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

class AggregationEventListItemCard extends StatelessWidget {
  const AggregationEventListItemCard({
    super.key,
    required this.event,
    this.isSelected = false,
    required this.onTap,
  });

  final AggregationEvent event;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    String truncateEpc(String? epc) {
      if (epc == null) return '—';
      if (epc.length <= 40) return epc;
      return '…${epc.substring(epc.length - 36)}';
    }

    final childCount = event.childEPCs.length;
    final locationName =
        event.businessLocation?.locationName ??
        event.businessLocation?.glnCode ??
        event.readPoint?.glnCode;
    final bizStep = AggregationEventUiConstants.friendlyBizStep(
      event.businessStep,
    );

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
            borderRadius: BorderRadius.circular(12),
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
                          truncateEpc(event.parentID),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Gs1ListItemSelectionStyle.primaryTextColor(
                              isSelected,
                            ),
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Gs1ListItemInfoRow(
                          AppAssets.iconLayers,
                          '${AggregationEventUiConstants.listCardItemCountPrefix}'
                          '$childCount child EPC${childCount == 1 ? '' : 's'}',

                          isSelected: isSelected,
                          muted: muted,
                          fontSize: 13,
                        ),
                        if (locationName != null)
                          Gs1ListItemInfoRow(
                            AppAssets.iconMapPin,
                            '${AggregationEventUiConstants.listCardLocationPrefix}$locationName',

                            isSelected: isSelected,
                            muted: muted,
                            fontSize: 13,
                          ),
                        if (event.businessStep != null)
                          Gs1ListItemInfoRow(
                            NavIcons.supplyChainTraversal,
                            '${AggregationEventUiConstants.listCardBizStepPrefix}$bizStep',

                            isSelected: isSelected,
                            muted: muted,
                            fontSize: 13,
                          ),
                        Gs1ListItemInfoRow(
                          AppAssets.iconClock,
                          dateFormat.format(event.eventTime.toLocal()),

                          isSelected: isSelected,
                          muted: muted,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AggregationEventActionChip(action: event.action),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
