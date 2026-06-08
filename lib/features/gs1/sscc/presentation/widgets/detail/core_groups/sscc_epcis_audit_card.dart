import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SsccEpcisAuditCard extends StatelessWidget {
  const SsccEpcisAuditCard({
    super.key,
    required this.borderColor,
    required this.sscc,
  });

  final Color borderColor;
  final SSCC? sscc;

  @override
  Widget build(BuildContext context) {
    if (sscc == null) {
      return const SizedBox.shrink();
    }

    return Gs1GroupCard(
      title: 'EPCIS & Audit',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SgtinInfoRow('SSCC URI', sscc!.ssccUri, monospace: true),
          const SizedBox(height: 12),
          SgtinInfoRow(
            'GS1 Digital Link',
            sscc!.gs1DigitalLinkUri,
            monospace: true,
          ),
          const SizedBox(height: 12),
          SgtinInfoRow(
            'Commissioning Event ID',
            sscc!.commissioningEventId,
            monospace: true,
          ),
          const SizedBox(height: 12),
          SgtinInfoRow(
            'Aggregation Event ID',
            sscc!.aggregationEventId,
            monospace: true,
          ),
          if (sscc!.nonReuseUntil != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Non-Reuse Until',
              ssccFormatDate(sscc!.nonReuseUntil),
            ),
          ],
          const SizedBox(height: 12),
          SgtinInfoRow('Created At', ssccFormatDt(sscc!.createdAt)),
          const SizedBox(height: 12),
          SgtinInfoRow('Updated At', ssccFormatDt(sscc!.updatedAt)),
        ],
      ),
    );
  }
}
