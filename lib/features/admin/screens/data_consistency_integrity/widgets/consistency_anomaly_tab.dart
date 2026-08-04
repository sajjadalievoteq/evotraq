import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_anomaly_card.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class ConsistencyAnomalyTab extends StatelessWidget {
  const ConsistencyAnomalyTab({
    super.key,
    required this.anomaliesState,
    required this.isDetectingAnomalies,
    required this.onDetectAnomalies,
    required this.onCorrectAnomaly,
    required this.onViewAnomalyDetails,
  });

  final LoadState<List<dynamic>> anomaliesState;
  final bool isDetectingAnomalies;
  final VoidCallback onDetectAnomalies;
  final void Function(Map<String, dynamic> anomaly) onCorrectAnomaly;
  final void Function(Map<String, dynamic> anomaly) onViewAnomalyDetails;

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
                        AppAssets.iconSearch,
                        color: AppColorMapper.warningColor(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Anomaly Detection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed:
                            isDetectingAnomalies ? null : onDetectAnomalies,
                        icon: isDetectingAnomalies
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : TraqIcon(AppAssets.iconSearch),
                        label: Text(
                          isDetectingAnomalies
                              ? 'Detecting...'
                              : 'Detect Anomalies',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LoadStateView<List<dynamic>>(
                    state: anomaliesState,
                    onRetry: onDetectAnomalies,
                    emptyWidget: const Text(
                      'No anomalies detected yet. Click "Detect Anomalies" to start scanning.',
                    ),
                    builder: (context, anomalies) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${anomalies.length} anomalies detected'),
                        const SizedBox(height: 16),
                        ...anomalies.map((anomaly) {
                          final map = Map<String, dynamic>.from(
                            anomaly as Map,
                          );
                          return ConsistencyAnomalyCard(
                            anomaly: map,
                            onCorrect: () => onCorrectAnomaly(map),
                            onViewDetails: () => onViewAnomalyDetails(map),
                          );
                        }),
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
