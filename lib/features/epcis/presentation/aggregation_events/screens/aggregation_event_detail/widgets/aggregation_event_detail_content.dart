import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_detail/utils/aggregation_event_detail_formatters.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_detail/widgets/aggregation_event_action_chip.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_detail/widgets/aggregation_event_detail_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utils/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/detail_header_banner_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class AggregationEventDetailContent extends StatelessWidget {
  const AggregationEventDetailContent({
    super.key,
    required this.event,
  });

  final AggregationEvent event;

  static final _eventTimeFormat = DateFormat('MMM dd, yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final bizStep =
        AggregationEventUiConstants.friendlyBizStep(event.businessStep);
    final disposition =
        AggregationEventUiConstants.friendlyDisposition(event.disposition);

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailHeaderBannerCard(
            title:
                '${AggregationEventUiConstants.listCardBizStepPrefix}$bizStep',
            subtitle:
                '${AggregationEventUiConstants.listCardDispositionPrefix}$disposition',
            footer: _eventTimeFormat.format(event.eventTime.toLocal()),
          ),
          const SizedBox(height: 16),
          Gs1GroupCard(
            title: AggregationEventUiConstants.sectionIdentification,
            outlineColor: Theme.of(context).colorScheme.outlineVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AggregationEventDetailField(
                        label: 'Event ID',
                        value: event.eventId,
                        monospace: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AggregationEventActionChip(action: event.action),
                  ],
                ),
                AggregationEventDetailField(
                  label: 'Database ID',
                  value: event.id,
                ),
                AggregationEventDetailField(
                  label: 'EPCIS Version',
                  value: AggregationEventDetailFormatters.epcisVersionLabel(
                    event.epcisVersion,
                  ),
                ),
                AggregationEventDetailField(
                  label: 'Event Time',
                  value: AggregationEventDetailFormatters.formatDateTime(
                    event.eventTime,
                  ),
                ),
                AggregationEventDetailField(
                  label: 'Record Time',
                  value: AggregationEventDetailFormatters.formatDateTime(
                    event.recordTime,
                  ),
                ),
                AggregationEventDetailField(
                  label: 'Time Zone Offset',
                  value: event.eventTimeZone,
                ),
              ],
            ),
          ),
          Gs1GroupCard(
            title: AggregationEventUiConstants.sectionHierarchy,
            outlineColor: Theme.of(context).colorScheme.outlineVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AggregationEventDetailField(
                  label: 'Parent EPC / SSCC',
                  value: event.parentID,
                  monospace: true,
                ),
                const SizedBox(height: 4),
                Text(
                  'Child EPCs (${event.childEPCs.length})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 6),
                if (event.childEPCs.isEmpty)
                  const Text('—')
                else
                  ...event.childEPCs.map(
                    (epc) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: epc));
                          context.showSuccess('Copied to clipboard');
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 6),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                epc,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontFamily: 'monospace'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Gs1GroupCard(
            title: AggregationEventUiConstants.sectionLocation,
            outlineColor: Theme.of(context).colorScheme.outlineVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AggregationEventDetailField(
                  label: 'Business Location',
                  value: event.businessLocation?.locationName ??
                      event.businessLocation?.glnCode,
                  monospace: event.businessLocation?.locationName == null,
                ),
                AggregationEventDetailField(
                  label: 'Read Point',
                  value: event.readPoint?.locationName ?? event.readPoint?.glnCode,
                  monospace: event.readPoint?.locationName == null,
                ),
              ],
            ),
          ),
          Gs1GroupCard(
            title: AggregationEventUiConstants.sectionBizStep,
            outlineColor: Theme.of(context).colorScheme.outlineVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AggregationEventDetailField(
                  label: 'Business Step',
                  value: AggregationEventUiConstants.friendlyBizStep(
                    event.businessStep,
                  ),
                ),
                AggregationEventDetailField(
                  label: 'Disposition',
                  value: AggregationEventUiConstants.friendlyDisposition(
                    event.disposition,
                  ),
                ),
                if (event.sourceList != null && event.sourceList!.isNotEmpty)
                  AggregationEventDetailField(
                    label: 'Sources',
                    value: event.sourceList!.map((e) => e.toString()).join(', '),
                  ),
                if (event.destinationList != null &&
                    event.destinationList!.isNotEmpty)
                  AggregationEventDetailField(
                    label: 'Destinations',
                    value: event.destinationList!
                        .map((e) => e.toString())
                        .join(', '),
                  ),
              ],
            ),
          ),
          if ((event.extensions != null && event.extensions!.isNotEmpty) ||
              (event.bizData != null && event.bizData!.isNotEmpty))
            Gs1GroupCard(
              title: AggregationEventUiConstants.sectionExtensions,
              outlineColor: Theme.of(context).colorScheme.outlineVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.bizData != null)
                    ...event.bizData!.entries.map(
                      (e) => AggregationEventDetailField(
                        label: e.key,
                        value: e.value.toString(),
                      ),
                    ),
                  if (event.extensions != null)
                    ...event.extensions!.entries.map(
                      (e) => AggregationEventDetailField(
                        label: e.key,
                        value: e.value.toString(),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: Constants.spacing * 2),
        ],
      ),
    );
  }
}
