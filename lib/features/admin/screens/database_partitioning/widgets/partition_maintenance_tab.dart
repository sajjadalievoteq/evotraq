import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_maintenance_actions.dart';

class PartitionMaintenanceTab extends StatelessWidget {
  const PartitionMaintenanceTab({
    super.key,
    required this.onPerformMaintenance,
  });

  final ValueChanged<String> onPerformMaintenance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partition Maintenance',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          PartitionMaintenanceActions(onPerformMaintenance: onPerformMaintenance),
        ],
      ),
    );
  }
}
