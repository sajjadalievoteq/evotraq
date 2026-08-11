import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_summary.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_empty_state.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_job_detail_row.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_job_status_chip.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_job_card.dart';

class BulkJobsList extends StatelessWidget {
  const BulkJobsList({
    required this.jobs,
    required this.onCancel,
    required this.onRetry,
    required this.onShowDetails,
  });

  final List<BulkJobStatus> jobs;
  final Function(String) onCancel;
  final Function(String) onRetry;
  final ValueChanged<BulkJobStatus> onShowDetails;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return BulkJobCard(
          job: job,
          onCancel: onCancel,
          onRetry: onRetry,
          onShowDetails: onShowDetails,
        );
      },
    );
  }
}
