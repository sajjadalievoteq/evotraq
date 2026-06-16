import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_event_action_chip.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';

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

    Widget infoRow(IconData icon, String text) {
      final color = Gs1ListItemSelectionStyle.mutedColor(isSelected, muted);
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    String truncateEpc(String? epc) {
      if (epc == null) return '—';
      if (epc.length <= 40) return epc;
      return '…${epc.substring(epc.length - 36)}';
    }

    final childCount = event.childEPCs?.length ?? 0;
    final locationName = event.businessLocation?.locationName ??
        event.businessLocation?.glnCode ??
        event.readPoint?.glnCode;
    final bizStep = AggregationEventUiConstants.friendlyBizStep(
        event.businessStep);

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
                                isSelected),
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        infoRow(
                          Icons.layers_outlined,
                          '${AggregationEventUiConstants.listCardChildCountPrefix}'
                          '$childCount child EPC${childCount == 1 ? '' : 's'}',
                        ),
                        if (locationName != null)
                          infoRow(
                            Icons.location_on_outlined,
                            '${AggregationEventUiConstants.listCardLocationPrefix}$locationName',
                          ),
                        if (event.businessStep != null)
                          infoRow(
                            Icons.route_outlined,
                            '${AggregationEventUiConstants.listCardBizStepPrefix}$bizStep',
                          ),
                        infoRow(
                          Icons.schedule_outlined,
                          dateFormat.format(event.eventTime.toLocal()),
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
