import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/core/utils/relative_time_utils.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/epcis/presentation/utils/epcis_event_ui_utils.dart';

class DashboardRecentEventTile extends StatelessWidget {
  const DashboardRecentEventTile({super.key, required this.event});

  final RecentEvent event;

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(event.eventTime);

    final eventColor = EpcisEventUiUtils.eventTypeColor(event.eventType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),

          leading: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: eventColor,
              shape: BoxShape.circle,
            ),
          ),

          title: Text(
            CbvDisplayUtils.displayBizStep(
                  event.bizStep,
                  fallback: event.eventType,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _identityText(event),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat(
                  isMobile
                      ? 'dd/MM/yyyy HH:mm'
                      : 'dd/MM/yyyy HH:mm:ss',
                ).format(event.eventTime),
                style: context.text.bodySm.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),

          trailing: SizedBox(
            width: isMobile ? 50 : 70,
            child: Text(
              timeAgo,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySm.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }

  String _identityText(RecentEvent event) {
    if (event.gtinCode != null && event.gtinCode!.isNotEmpty) {
      final parts = [event.gtinCode!];
      if (event.batchLotNumber != null && event.batchLotNumber!.isNotEmpty) {
        parts.add(event.batchLotNumber!);
      }
      final count = event.epcList.length;
      if (count > 0) parts.add('$count serial${count == 1 ? '' : 's'}');
      return parts.join(' · ');
    }

    final epcCount = event.epcList.length;

    if (event.eventType.toLowerCase() == 'aggregationevent') {
      final parent = _shortId(event.parentId);
      if (epcCount > 0) return '$parent · $epcCount item${epcCount == 1 ? '' : 's'}';
      return parent;
    }

    if (event.eventType.toLowerCase() == 'transformationevent') {
      if (event.inputEpcCount > 0 || epcCount > 0) {
        return '${event.inputEpcCount} in → $epcCount out';
      }
    }

    if (epcCount > 0) return '$epcCount item${epcCount == 1 ? '' : 's'}';

    return event.id;
  }

  String _shortId(String? epc) {
    if (epc == null || epc.isEmpty) return '–';
    if (Gs1CanonicalIdentifier.isSgtin(epc)) {
      final gtin = Gs1CanonicalIdentifier.extractGtin(epc);
      if (gtin != null && gtin.length == 14) {
        return '${gtin.substring(1, 8)}.${gtin.substring(8)}';
      }
    }
    if (Gs1CanonicalIdentifier.isSscc(epc)) {
      final sscc = Gs1CanonicalIdentifier.extractSscc18(epc);
      if (sscc != null) return sscc;
    }
    return epc.length > 20 ? '…${epc.substring(epc.length - 16)}' : epc;
  }

  String _formatTimeAgo(DateTime dateTime) {
    return RelativeTimeUtils.compactAgo(dateTime);
  }
}
