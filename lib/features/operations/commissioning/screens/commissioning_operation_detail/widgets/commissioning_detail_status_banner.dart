import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_count_badge.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_batch_status_utils.dart';

class CommissioningDetailStatusBanner extends StatelessWidget {
  const CommissioningDetailStatusBanner({
    super.key,
    required this.batch,
  });

  final CommissioningBatch batch;

  @override
  Widget build(BuildContext context) {
    final statusColor = CommissioningBatchStatusUtils.color(batch.status);

    return Card(
      elevation: 2,
      color: context.colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.primary,
          image: DecorationImage(
            image: AssetImage(AppAssets.traqBackgroundPng),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CommissioningBatchStatusUtils.icon(batch.status),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          CommissioningBatchStatusUtils.detailLabel(
                            batch.status,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CommissioningDetailCountBadge(
                        text: '${batch.totalCommissioned} Commissioned',
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                      if (batch.totalFailed > 0) ...[
                        const SizedBox(height: 4),
                        CommissioningDetailCountBadge(
                          text: '${batch.totalFailed} Failed',
                          color: Colors.red,
                          icon: Icons.error,
                        ),
                      ],
                      if (batch.totalRequested > 0) ...[
                        const SizedBox(height: 4),
                        CommissioningDetailCountBadge(
                          text: '${batch.totalRequested} Requested',
                          color: Colors.grey,
                          icon: Icons.pending,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
