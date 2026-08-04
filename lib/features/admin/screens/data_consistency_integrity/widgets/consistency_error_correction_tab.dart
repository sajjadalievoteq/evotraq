import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_correctable_error_card.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_correction_statistics_card.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class ConsistencyErrorCorrectionTab extends StatelessWidget {
  const ConsistencyErrorCorrectionTab({
    super.key,
    required this.correctionStatisticsState,
    required this.correctableErrors,
    required this.isIdentifyingErrors,
    required this.onLoadCorrectionStatistics,
    required this.onIdentifyCorrectableErrors,
    required this.onShowCorrectionDialog,
  });

  final LoadState<Map<String, dynamic>> correctionStatisticsState;
  final List<dynamic> correctableErrors;
  final bool isIdentifyingErrors;
  final VoidCallback onLoadCorrectionStatistics;
  final VoidCallback onIdentifyCorrectableErrors;
  final void Function(Map<String, dynamic> error) onShowCorrectionDialog;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadStateView<Map<String, dynamic>>(
            state: correctionStatisticsState,
            onRetry: onLoadCorrectionStatistics,
            emptyWidget: const SizedBox.shrink(),
            builder: (context, stats) =>
                ConsistencyCorrectionStatisticsCard(stats),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(
                        AppAssets.iconSettings,
                        color: AppColorMapper.successColor(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Correctable Errors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: isIdentifyingErrors
                            ? null
                            : onIdentifyCorrectableErrors,
                        icon: isIdentifyingErrors
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : TraqIcon(AppAssets.iconSearch),
                        label: Text(
                          isIdentifyingErrors
                              ? 'Identifying...'
                              : 'Identify Errors',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (correctableErrors.isNotEmpty) ...[
                    Text('${correctableErrors.length} correctable errors found'),
                    const SizedBox(height: 16),
                    ...correctableErrors.map((error) {
                      final map = Map<String, dynamic>.from(error as Map);
                      return ConsistencyCorrectableErrorCard(
                        error: map,
                        onCorrect: () => onShowCorrectionDialog(map),
                      );
                    }),
                  ] else
                    const Text(
                      'No correctable errors identified yet. Click "Identify Errors" to start scanning.',
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
