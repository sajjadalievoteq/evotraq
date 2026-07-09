import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SgtinCommissioningCard extends StatelessWidget {
  const SgtinCommissioningCard({
    super.key,
    required this.borderColor,
    this.sgtin,
  });

  final Color borderColor;
  final SGTIN? sgtin;

  bool get _isCommissioned =>
      sgtin?.commissioningEventId != null || sgtin?.commissionedAt != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Gs1GroupCard(
      title: 'Commissioning',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isCommissioned)
            Text(
              'Not yet commissioned',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            if (sgtin?.currentLocation != null)
              SgtinInfoRow(
                'Commissioning Location',
                '${sgtin!.currentLocation!.glnCode} – '
                    '${sgtin!.currentLocation!.locationName}',
              ),
            if (sgtin?.commissioningReadpointGln != null) ...[
              if (sgtin?.currentLocation != null) const SizedBox(height: 12),
              SgtinInfoRow(
                'Commissioning Readpoint GLN',
                sgtin!.commissioningReadpointGln,
              ),
            ],
            if (sgtin?.commissioningEventId != null) ...[
              const SizedBox(height: 12),
              SgtinInfoRow(
                'Commissioning Event ID',
                sgtin!.commissioningEventId,
                monospace: true,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
