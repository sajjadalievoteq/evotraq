import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class PartitionHealthStatusCard extends StatelessWidget {
  const PartitionHealthStatusCard(this.healthStatus, {super.key});

  final Map<String, dynamic> healthStatus;

  @override
  Widget build(BuildContext context) {
    final status = healthStatus['overall_status'] ?? 'UNKNOWN';
    late Color statusColor;
    late String statusIconAsset;

    switch (status) {
      case 'HEALTHY':
        statusColor = AppColorMapper.successColor(context);
        statusIconAsset = AppAssets.iconCheckCircle;
        break;
      case 'WARNING':
        statusColor = AppColorMapper.warningColor(context);
        statusIconAsset = AppAssets.iconAlert;
        break;
      case 'CRITICAL':
        statusColor = AppColorMapper.errorColor(context);
        statusIconAsset = AppAssets.iconXCircle;
        break;
      default:
        statusColor = Colors.grey;
        statusIconAsset = NavIcons.helpSupport;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(statusIconAsset, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  'System Health: $status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            if (healthStatus['issues'] != null &&
                (healthStatus['issues'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${(healthStatus['issues'] as List).length} issue(s) found',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
