import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_metrics_section.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_violations_section.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class ConsistencyValidationTab extends StatelessWidget {
  const ConsistencyValidationTab({
    super.key,
    required this.reportState,
    required this.isGeneratingReport,
    required this.onGenerateReport,
    required this.onCorrectViolation,
    required this.onViewViolationDetails,
  });

  final LoadState<Map<String, dynamic>> reportState;
  final bool isGeneratingReport;
  final VoidCallback onGenerateReport;
  final void Function(Map<String, dynamic> violation) onCorrectViolation;
  final void Function(Map<String, dynamic> violation) onViewViolationDetails;

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
                        AppAssets.iconList,
                        color: AppColorMapper.infoColor(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Consistency Validation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed:
                            isGeneratingReport ? null : onGenerateReport,
                        icon: isGeneratingReport
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : TraqIcon(AppAssets.iconArrowR),
                        label: Text(
                          isGeneratingReport
                              ? 'Generating...'
                              : 'Generate Report',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LoadStateView<Map<String, dynamic>>(
                    state: reportState,
                    onRetry: onGenerateReport,
                    emptyWidget: const Text(
                      'No consistency report generated yet. Click "Generate Report" to start.',
                    ),
                    builder: (context, report) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConsistencyMetricsSection(report),
                        const SizedBox(height: 16),
                        ConsistencyViolationsSection(
                          report: report,
                          onCorrect: onCorrectViolation,
                          onViewDetails: onViewViolationDetails,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
