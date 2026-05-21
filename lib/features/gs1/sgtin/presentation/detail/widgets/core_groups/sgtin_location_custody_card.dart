import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

/// Read-only current location and custody card for the SGTIN detail screen.
///
/// Shows the current location GLN, location name, custodian GLN, SSCC
/// container, parent EPC, and aggregation timestamp. Only rendered when
/// viewing an existing SGTIN record.
class SgtinLocationCustodyCard extends StatelessWidget {
  const SgtinLocationCustodyCard({
    super.key,
    required this.sgtin,
    required this.borderColor,
  });

  final SGTIN sgtin;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Current Location & Custody',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SgtinInfoRow(
            'Current Location GLN',
            sgtin.currentLocation?.glnCode,
          ),
          if (sgtin.currentLocation?.locationName != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Location Name',
              sgtin.currentLocation!.locationName,
            ),
          ],
          const SizedBox(height: 12),
          SgtinInfoRow(
            'Current Custodian GLN',
            sgtin.currentCustodianGln,
          ),
          if (sgtin.currentSSCC != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Current SSCC (Container)',
              sgtin.currentSSCC!.ssccCode,
            ),
          ],
          if (sgtin.parentEpc != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Parent EPC (Aggregation)',
              sgtin.parentEpc,
              monospace: true,
            ),
          ],
          if (sgtin.aggregatedAt != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Aggregated At',
              sgtinFormatDt(sgtin.aggregatedAt),
            ),
          ],
        ],
      ),
    );
  }
}
