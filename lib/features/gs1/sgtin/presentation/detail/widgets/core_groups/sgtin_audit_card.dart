import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

/// Read-only audit card for the SGTIN detail screen.
///
/// Shows created-at, created-by, and last-updated timestamps. Only rendered
/// when viewing an existing SGTIN record.
class SgtinAuditCard extends StatelessWidget {
  const SgtinAuditCard({
    super.key,
    required this.sgtin,
    required this.borderColor,
  });

  final SGTIN sgtin;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Audit',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SgtinInfoRow('Created At', sgtinFormatDt(sgtin.createdAt)),
          if (sgtin.createdBy != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow('Created By', sgtin.createdBy),
          ],
          const SizedBox(height: 12),
          SgtinInfoRow('Last Updated', sgtinFormatDt(sgtin.updatedAt)),
        ],
      ),
    );
  }
}
