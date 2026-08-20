import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_info_row.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_events_list/utils/object_event_list_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/object_events/utils/object_event_shared_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/object_events/widgets/object_event_action_chip.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';

import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

class ObjectEventListItemCard extends StatelessWidget {
  const ObjectEventListItemCard({
    super.key,
    required this.event,
    this.isSelected = false,
    required this.onTap,
  });

  final ObjectEvent event;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    final epcList = event.epcList ?? [];
    final primaryEpc = epcList.isNotEmpty ? epcList.first : null;
    final additionalCount = epcList.length > 1 ? epcList.length - 1 : 0;
    final locationGln = event.businessLocation ?? event.readPoint;
    final locationName = locationGln != null
        ? glnDisplayLabel(locationGln)
        : null;
    final bizStep = ObjectEventSharedUiConstants.friendlyBizStep(
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
                          event.eventId,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Gs1ListItemSelectionStyle.primaryTextColor(
                              isSelected,
                            ),
                            fontFamily: primaryEpc != null ? 'monospace' : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (additionalCount > 0)
                          Gs1ListItemInfoRow(
                            AppAssets.iconBox,
                            '${ObjectEventListUiConstants.listCardEpcPrefix}+$additionalCount more EPC${additionalCount == 1 ? '' : 's'}',

                            isSelected: isSelected,
                            muted: muted,
                            fontSize: 13,
                          ),
                        if (locationName != null)
                          Gs1ListItemInfoRow(
                            AppAssets.iconMapPin,
                            '${ObjectEventListUiConstants.listCardLocationPrefix}$locationName',

                            isSelected: isSelected,
                            muted: muted,
                            fontSize: 13,
                          ),
                        if (event.businessStep != null)
                          Gs1ListItemInfoRow(
                            NavIcons.supplyChainTraversal,
                            '${ObjectEventListUiConstants.listCardBizStepPrefix}$bizStep',

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
                  ObjectEventActionChip(action: event.action),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
