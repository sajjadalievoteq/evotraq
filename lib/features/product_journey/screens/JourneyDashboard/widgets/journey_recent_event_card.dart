import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/utils/epcis_event_ui_utils.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';

/// Recent-event list card styled to match [OperationListCard], bound to [RecentEvent].
class JourneyRecentEventCard extends StatelessWidget {
  const JourneyRecentEventCard({
    super.key,
    required this.event,
    this.isSelected = false,
    required this.onTap,
  });

  final RecentEvent event;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final titleColor =
        Gs1ListItemSelectionStyle.primaryTextColor(isSelected);
    final rowColor =
        Gs1ListItemSelectionStyle.mutedColor(isSelected, muted);

    final chipColor = EpcisEventUiUtils.eventTypeColor(event.eventType);
    final chipLabel = _chipLabel();
    final title = _title();
    final rows = _rows();
    final countLabel = _countLabel();
    final stepIcon = JourneyStepStyle.iconFor(event.bizStep ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chipLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (countLabel != null)
                    Text(
                      countLabel,
                      style: TextStyle(
                        color: rowColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TraqIcon(stepIcon, size: 20, color: titleColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final row in rows) ...[
                _RowLine(row: row, color: rowColor),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _chipLabel() {
    final raw = event.eventType.trim();
    if (raw.isEmpty) return 'Event';
    final lower = raw.toLowerCase();
    if (lower.contains('object')) return 'Object';
    if (lower.contains('aggregation')) return 'Aggregation';
    if (lower.contains('transaction')) return 'Transaction';
    if (lower.contains('transformation')) return 'Transformation';
    return raw
        .replaceAll(RegExp(r'Event$', caseSensitive: false), '')
        .trim();
  }

  String _title() {
    final biz = event.bizStep?.trim();
    if (biz != null && biz.isNotEmpty) {
      return JourneyStepStyle.titleFor(biz);
    }
    return CbvDisplayUtils.displayBizStep(
      null,
      fallback: event.eventType.isNotEmpty ? event.eventType : 'Event',
    );
  }

  String? _countLabel() {
    final n = event.epcList.length;
    if (n <= 0) return null;
    return '$n EPC${n == 1 ? '' : 's'}';
  }

  List<_CardRow> _rows() {
    final rows = <_CardRow>[];

    void add(String? text, String icon) {
      final value = text?.trim();
      if (value == null || value.isEmpty) return;
      rows.add(_CardRow(text: value, iconAsset: icon));
    }

    final epc = event.epcList
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .firstOrNull;
    add(epc, NavIcons.packaging);

    final gtin = event.gtinCode?.trim();
    if (gtin != null && gtin.isNotEmpty) {
      add('GTIN: $gtin', NavIcons.gtin);
    }

    final lot = event.batchLotNumber?.trim();
    if (lot != null && lot.isNotEmpty) {
      add('Lot #: $lot', AppAssets.iconQr);
    }

    add(
      DateFormat('MMM dd, yyyy HH:mm').format(event.eventTime.toLocal()),
      AppAssets.iconCalendar,
    );

    return rows;
  }
}

class _CardRow {
  const _CardRow({required this.text, required this.iconAsset});

  final String text;
  final String iconAsset;
}

class _RowLine extends StatelessWidget {
  const _RowLine({required this.row, required this.color});

  final _CardRow row;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TraqIcon(row.iconAsset, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            row.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}
