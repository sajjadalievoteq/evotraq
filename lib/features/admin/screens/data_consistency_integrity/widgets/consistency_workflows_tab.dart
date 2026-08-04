import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_correction_workflow_card.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class ConsistencyWorkflowsTab extends StatelessWidget {
  const ConsistencyWorkflowsTab({
    super.key,
    required this.workflowDataState,
    required this.correctionWorkflowsCount,
    required this.onRefreshWorkflowData,
    required this.onLoadWorkflowData,
    required this.onShowWorkflowDetails,
  });

  final LoadState<List<Map<String, dynamic>>> workflowDataState;
  final int correctionWorkflowsCount;
  final VoidCallback onRefreshWorkflowData;
  final VoidCallback onLoadWorkflowData;
  final void Function(Map<String, dynamic> workflow) onShowWorkflowDetails;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(
                        AppAssets.iconGlobe,
                        color: AppColorMapper.chartColor(context, 5),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Correction Workflows',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: onRefreshWorkflowData,
                        icon: TraqIcon(AppAssets.iconRefresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Active Workflows: $correctionWorkflowsCount',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          LoadStateView<List<Map<String, dynamic>>>(
            state: workflowDataState,
            onRetry: onLoadWorkflowData,
            emptyWidget: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      TraqIcon(
                        AppAssets.iconGlobe,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No correction workflows found (Length: $correctionWorkflowsCount)',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start error corrections from the Error Correction tab to see workflows here.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: onLoadWorkflowData,
                        child: const Text('Load Workflows'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            builder: (context, workflows) => Column(
              children: workflows.map((workflow) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ConsistencyCorrectionWorkflowCard(
                    workflow: workflow,
                    onTap: () => onShowWorkflowDetails(workflow),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
