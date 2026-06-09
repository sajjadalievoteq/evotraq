import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SgtinEpcisSnapshotCard extends StatelessWidget {
  const SgtinEpcisSnapshotCard({
    super.key,
    required this.sgtin,
    required this.borderColor,
  });

  final SGTIN sgtin;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
