import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SgtinEpcisSnapshotCard extends StatelessWidget {
  const SgtinEpcisSnapshotCard({
    super.key,
    required this.sgtin,
    required this.borderColor,
  });

  final SGTIN sgtin;
  final Color borderColor;

  void _openObjectEventForm(BuildContext context) {
    final params = <String, String>{};
    if (sgtin.latestDisposition != null &&
        sgtin.latestDisposition!.trim().isNotEmpty) {
      params['currentItemDisposition'] = sgtin.latestDisposition!.trim();
    }
    final epc = sgtin.canonicalIdentifier?.trim();
    if (epc != null && epc.isNotEmpty) {
      params['epcs'] = epc;
    }
    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
    final path = query.isEmpty
        ? Constants.epcisObjectEventNewRoute
        : '${Constants.epcisObjectEventNewRoute}?$query';
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final canRecordEvent =
        sgtin.canonicalIdentifier != null || sgtin.latestDisposition != null;

    return Gs1GroupCard(
      title: 'EPCIS Event Snapshot',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SgtinInfoRow('Latest Business Step', sgtin.latestBizStep),
          if (sgtin.latestDisposition != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow('Latest Disposition', sgtin.latestDisposition),
          ],
          if (sgtin.latestEventId != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Latest Event ID',
              sgtin.latestEventId,
              monospace: true,
            ),
          ],
          if (canRecordEvent) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openObjectEventForm(context),
              icon: const TraqIcon(AppAssets.iconCalendar, size: 18),
              label: const Text('Record Object Event'),
            ),
          ],
        ],
      ),
    );
  }
}
