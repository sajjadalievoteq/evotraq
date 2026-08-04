import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_summary_card.dart';

class BulkJobsSummary extends StatelessWidget {
  const BulkJobsSummary(this.jobs, {super.key});

  final List<BulkJobStatus> jobs;

  @override
  Widget build(BuildContext context) {

    final running = jobs.where((j) => j.status == 'RUNNING').length;
    final completed = jobs.where((j) => j.status == 'COMPLETED').length;
    final failed = jobs.where((j) => j.status == 'FAILED').length;
    final pending = jobs.where((j) => j.status == 'PENDING').length;

    return Row(
      children: [
        BulkJobsSummaryCard('Running', running, AppColorMapper.infoColor(context)),
        const SizedBox(width: 8),
        BulkJobsSummaryCard('Completed', completed, AppColorMapper.successColor(context)),
        const SizedBox(width: 8),
        BulkJobsSummaryCard('Failed', failed, AppColorMapper.errorColor(context)),
        const SizedBox(width: 8),
        BulkJobsSummaryCard('Pending', pending, AppColorMapper.warningColor(context)),
      ],
    );
  }
}