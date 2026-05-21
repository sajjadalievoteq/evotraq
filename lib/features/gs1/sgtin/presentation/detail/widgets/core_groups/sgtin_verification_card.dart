import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

/// Read-only VRS verification card for the SGTIN detail screen.
///
/// Shows verification status, verification count, alert count (with warning
/// colour), and retention expiry. Only rendered when viewing an existing
/// SGTIN record.
class SgtinVerificationCard extends StatelessWidget {
  const SgtinVerificationCard({
    super.key,
    required this.sgtin,
    required this.borderColor,
  });

  final SGTIN sgtin;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Verification (VRS)',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SgtinInfoRow('Verification Status', sgtin.verificationStatus),
          const SizedBox(height: 12),
          SgtinInfoRow(
            'Verification Count',
            sgtin.verificationCount.toString(),
          ),
          if (sgtin.alertCount > 0) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Alert Count',
              sgtin.alertCount.toString(),
              valueColor: Colors.orange.shade700,
            ),
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Retention Expiry',
              sgtinFormatDt(sgtin.retentionExpiry),
            ),
          ],
        ],
      ),
    );
  }
}
