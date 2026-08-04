import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_maintenance_button.dart';

class PartitionMaintenanceActions extends StatelessWidget {
  const PartitionMaintenanceActions({
    super.key,
    required this.onPerformMaintenance,
  });

  final ValueChanged<String> onPerformMaintenance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PartitionMaintenanceButton(
          'Create Future Partitions',
          'Create partitions for next 3 months (epcis_events only)',
          AppAssets.iconPlus,
          () => onPerformMaintenance('CREATE_FUTURE'),
        ),
        const SizedBox(height: 12),
        PartitionMaintenanceButton(
          'Update Statistics',
          'Refresh partition statistics',
          AppAssets.iconRefresh,
          () => onPerformMaintenance('UPDATE_STATS'),
        ),
        const SizedBox(height: 12),
        PartitionMaintenanceButton(
          'Archive Old Partitions',
          'Archive partitions older than 12 months',
          AppAssets.iconArchive,
          () => onPerformMaintenance('ARCHIVE_OLD'),
        ),
        const SizedBox(height: 12),
        PartitionMaintenanceButton(
          'Health Check',
          'Perform comprehensive health check',
          AppAssets.iconSecurity,
          () => onPerformMaintenance('HEALTH_CHECK'),
        ),
      ],
    );
  }
}
