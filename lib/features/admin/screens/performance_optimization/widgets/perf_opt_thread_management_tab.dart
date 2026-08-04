import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_thread_pool_config_form.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class PerfOptThreadManagementTab extends StatelessWidget {
  const PerfOptThreadManagementTab({
    super.key,
    required this.reportState,
    required this.onRetry,
    required this.onConfigureThreadPool,
  });

  final LoadState<Map<String, dynamic>> reportState;
  final VoidCallback onRetry;
  final VoidCallback onConfigureThreadPool;

  @override
  Widget build(BuildContext context) {
    return LoadStateView<Map<String, dynamic>>(
      state: reportState,
      onRetry: onRetry,
      builder: (context, report) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thread Pool Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Configure optimal thread pool settings:'),
                    const SizedBox(height: 16),
                    PerfOptThreadPoolConfigForm(
                      onConfigure: onConfigureThreadPool,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
