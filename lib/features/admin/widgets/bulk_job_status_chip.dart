import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';

class BulkJobStatusChip extends StatelessWidget {
  const BulkJobStatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: StatusVisualMappers.bulkJobStatusColor(context, status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: StatusVisualMappers.bulkJobStatusColor(context, status).withOpacity(0.3),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: StatusVisualMappers.bulkJobStatusColor(context, status),
        ),
      ),
    );
  }
}