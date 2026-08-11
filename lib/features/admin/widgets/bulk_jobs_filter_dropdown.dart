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

class BulkJobsFilterDropdown extends StatelessWidget {
  const BulkJobsFilterDropdown({
    required this.selectedFilter,
    required this.onChanged,
  });

  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedFilter,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      items: const [
        DropdownMenuItem(value: 'ALL', child: Text('All Jobs')),
        DropdownMenuItem(value: 'RUNNING', child: Text('Running')),
        DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
        DropdownMenuItem(value: 'FAILED', child: Text('Failed')),
        DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
      ],
    );
  }
}
