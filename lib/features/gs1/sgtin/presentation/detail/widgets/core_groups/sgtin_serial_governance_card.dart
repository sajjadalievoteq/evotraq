import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SgtinSerialGovernanceCard extends StatelessWidget {
  const SgtinSerialGovernanceCard({
    super.key,
    required this.sgtin,
    required this.borderColor,
  });

  final SGTIN sgtin;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Serial Governance',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SgtinInfoRow(
            'Generation Strategy',
            sgtin.serialGenerationStrategy,
          ),
          if (sgtin.serialOrigin != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow('Serial Origin', sgtin.serialOrigin),
          ],
          if (sgtin.serialRangeId != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Serial Range ID',
              sgtin.serialRangeId,
              monospace: true,
            ),
          ],
          if (sgtin.serialGuessingProbability != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Guessing Probability',
              sgtinFormatGuessingProb(sgtin.serialGuessingProbability!),
            ),
          ],
          if (sgtin.serialEntropySeed != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Entropy Source',
              sgtin.serialEntropySeed,
              monospace: true,
            ),
          ],
        ],
      ),
    );
  }
}
