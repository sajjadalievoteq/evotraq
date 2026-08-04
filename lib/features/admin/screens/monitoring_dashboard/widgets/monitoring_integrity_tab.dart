import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/integrity_statistics_card.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class MonitoringIntegrityTab extends StatelessWidget {
  const MonitoringIntegrityTab({
    super.key,
    required this.integrityState,
    required this.onRetry,
    required this.onVerifyIntegrity,
  });

  final LoadState<IntegrityStatistics> integrityState;
  final VoidCallback onRetry;
  final void Function(String eventId) onVerifyIntegrity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LoadStateView<IntegrityStatistics>(
        state: integrityState,
        onRetry: onRetry,
        builder: (context, integrity) => Column(
          children: [
            IntegrityStatisticsCard(
              integrity: integrity,
              onVerifyIntegrity: onVerifyIntegrity,
            ),
          ],
        ),
      ),
    );
  }
}
