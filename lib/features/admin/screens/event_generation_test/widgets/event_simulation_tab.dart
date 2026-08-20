import 'package:traqtrace_app/data/services/admin/event_generation_test_models.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class EventSimulationTab extends StatelessWidget {
  const EventSimulationTab({
    required this.activeSimulation,
    required this.simulationStatus,
    required this.simulationParams,
    required this.isLoading,
    required this.statusColor,
    required this.statusText,
    required this.onDurationChanged,
    required this.onEventIntervalChanged,
    required this.onIncludeAnomaliesChanged,
    required this.onAnomalyRateChanged,
    required this.onStart,
    required this.onStop,
    required this.onRefresh,
    required this.onClear,
    super.key,
  });

  final SimulationSession? activeSimulation;
  final SimulationStatus? simulationStatus;
  final Map<String, dynamic> simulationParams;
  final bool isLoading;
  final Color statusColor;
  final String statusText;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<int> onEventIntervalChanged;
  final ValueChanged<bool> onIncludeAnomaliesChanged;
  final ValueChanged<double> onAnomalyRateChanged;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRefresh;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Supply Chain Simulation',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (activeSimulation != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Session ID: ${activeSimulation!.sessionId}'),
                      Text('Status: ${activeSimulation!.status}'),
                      if (simulationStatus != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Current Events: ${simulationStatus!.currentEvents}',
                        ),
                        Text(
                          'Progress: ${simulationStatus!.progressPercentage.toStringAsFixed(1)}%',
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: simulationStatus!.progressPercentage / 100,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          isLoading || simulationStatus?.status != 'RUNNING'
                          ? null
                          : onStop,
                      icon: const TraqIcon(AppAssets.iconX),
                      label: const Text('Stop Simulation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : onRefresh,
                      icon: const TraqIcon(AppAssets.iconRefresh),
                      label: const Text('Refresh Status'),
                    ),
                    if ({
                      'COMPLETED',
                      'ERROR',
                      'STOPPED',
                    }.contains(simulationStatus?.status)) ...[
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: onClear,
                        icon: const TraqIcon(AppAssets.iconX),
                        label: const Text('Clear'),
                      ),
                    ],
                  ],
                ),
              ] else ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Duration (seconds)',
                    border: OutlineInputBorder(),
                    helperText: 'How long to run the simulation',
                  ),
                  initialValue: simulationParams['duration'].toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      onDurationChanged(int.tryParse(value) ?? 300),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Event Interval (ms)',
                    border: OutlineInputBorder(),
                    helperText: 'Time between events',
                  ),
                  initialValue: simulationParams['eventInterval'].toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      onEventIntervalChanged(int.tryParse(value) ?? 1000),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Include Anomalies'),
                  subtitle: const Text('Inject anomalies into simulation'),
                  value: simulationParams['includeAnomalies'] ?? false,
                  onChanged: onIncludeAnomaliesChanged,
                ),
                if (simulationParams['includeAnomalies'] == true) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Anomaly Rate (0.0 - 1.0)',
                      border: OutlineInputBorder(),
                      helperText: 'Percentage of events that will be anomalies',
                    ),
                    initialValue: simulationParams['anomalyRate'].toString(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) =>
                        onAnomalyRateChanged(double.tryParse(value) ?? 0.05),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onStart,
                  icon: const TraqIcon(AppAssets.iconArrowR),
                  label: const Text('Start Simulation'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
