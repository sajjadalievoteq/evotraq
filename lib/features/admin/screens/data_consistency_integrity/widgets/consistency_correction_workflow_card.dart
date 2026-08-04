import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ConsistencyCorrectionWorkflowCard extends StatelessWidget {
  const ConsistencyCorrectionWorkflowCard({
    super.key,
    required this.workflow,
    required this.onTap,
  });

  final Map<String, dynamic> workflow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final workflowId = workflow['workflow_id'] ?? 'UNKNOWN';
    final status = workflow['status'] ?? 'UNKNOWN';
    final sourceJobId = workflow['source_job_id'] ?? 'UNKNOWN';
    final workflowType = workflow['workflow_type'] ?? 'UNKNOWN';
    final currentStep = workflow['violation_count'] ?? 0;
    final createdTime = workflow['created_time'] as DateTime?;
    final completionTime = workflow['completion_time'];
    final executionResults = workflow['execution_results'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              StatusVisualMappers.workflowStatusColor(context, status),
          child: TraqIcon(
            StatusVisualMappers.workflowStatusIcon(status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text('Workflow: $workflowId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $workflowType'),
            Text('Source: $sourceJobId'),
            Text('Step: $currentStep'),
            if (createdTime != null)
              Text('Created: ${createdTime.toString().substring(0, 19)}'),
            if (status.toUpperCase() == 'COMPLETED' &&
                executionResults != null &&
                executionResults['corrected_violations'] != null)
              Text(
                'Corrected: ${(executionResults['corrected_violations'] as List).length} violations',
                style: TextStyle(color: AppColorMapper.successColor(context)),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: StatusVisualMappers.workflowStatusColor(context, status),
              ),
            ),
            if (completionTime != null)
              Text(
                'Completed',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColorMapper.successColor(context),
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
