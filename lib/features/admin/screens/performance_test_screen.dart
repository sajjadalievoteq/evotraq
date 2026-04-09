import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/features/admin/services/performance_test_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

class PerformanceTestScreen extends StatefulWidget {
  const PerformanceTestScreen({Key? key}) : super(key: key);

  @override
  State<PerformanceTestScreen> createState() => _PerformanceTestScreenState();
}

class _PerformanceTestScreenState extends State<PerformanceTestScreen> {
  PerformanceTestService? _testService;
  bool _isLoading = false;
  Map<String, PerformanceTestResult>? _allTestResults;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // It's safe to use context.read<AuthCubit>() here
    _testService ??= PerformanceTestService(
      baseUrl: getIt<AppConfig>().apiBaseUrl,
    );
  }

  Future<void> _runAllTests() async {
    // Make sure service is initialized
    if (_testService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _testService!.runAllPerformanceTests();
      setState(() {
        _allTestResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to run tests: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _runSingleTest(
    String testName,
    Future<PerformanceTestResult> Function() testFn,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await testFn();
      setState(() {
        _allTestResults = _allTestResults ?? {};
        _allTestResults![testName] = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to run test: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _runFrontendTests() async {
    // Make sure service is initialized
    if (_testService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final frontendGS1Test = await _testService!
          .runFrontendGS1ValidationPerformanceTest();
      final frontendBarcodeTest = await _testService!
          .runFrontendBarcodeParsingPerformanceTest();

      setState(() {
        _allTestResults = _allTestResults ?? {};
        _allTestResults!['frontendGS1Validation'] = frontendGS1Test;
        _allTestResults!['frontendBarcodeParsing'] = frontendBarcodeTest;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to run frontend tests: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode
        ? AppTheme.primaryColorDark
        : AppTheme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Tests'),
        backgroundColor: primaryColor,
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLoadingIndicator(),
                  const SizedBox(height: 16),
                  const Text('Running performance tests...'),
                ],
              ),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _runAllTests, child: const Text('Retry')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTestControls(),
          const SizedBox(height: 24),
          _buildTestResults(),
        ],
      ),
    );
  }

  Widget _buildTestControls() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Test Suite',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Run data model and GS1 validation performance tests to ensure the system meets requirements.',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Backend Tests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _runAllTests,
                  child: const Text('Run All Backend Tests'),
                ),
                OutlinedButton(
                  onPressed: _testService == null
                      ? null
                      : () => _runSingleTest(
                          'gs1Validation',
                          _testService!.runGS1ValidationPerformanceTest,
                        ),
                  child: const Text('GS1 Validation'),
                ),
                OutlinedButton(
                  onPressed: _testService == null
                      ? null
                      : () => _runSingleTest(
                          'batchInsertion',
                          _testService!.runBatchInsertionPerformanceTest,
                        ),
                  child: const Text('Batch Insertion'),
                ),
                OutlinedButton(
                  onPressed: _testService == null
                      ? null
                      : () => _runSingleTest(
                          'queryCaching',
                          _testService!.runQueryCachingPerformanceTest,
                        ),
                  child: const Text('Query Caching'),
                ),
                OutlinedButton(
                  onPressed: _testService == null
                      ? null
                      : () => _runSingleTest(
                          'barcodeParsing',
                          _testService!.runBarcodeParsingPerformanceTest,
                        ),
                  child: const Text('Barcode Parsing'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Frontend Tests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _runFrontendTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
              ),
              child: const Text('Run Frontend Tests'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    if (_allTestResults == null || _allTestResults!.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No tests have been run yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Use the controls above to run performance tests'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Test Results', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ..._allTestResults!.entries.map((entry) {
          final testKey = entry.key;
          final result = entry.value;

          final isBackendTest = !testKey.startsWith('frontend');
          final testGroup = isBackendTest ? 'Backend' : 'Frontend';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isBackendTest
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isBackendTest ? Colors.blue : Colors.amber,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          testGroup,
                          style: TextStyle(
                            color: isBackendTest
                                ? Colors.blue[700]
                                : Colors.amber[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.testName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _buildStatusBadge(result.passed),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildMetricRow(
                    'Operations per second',
                    '${result.operationsPerSecond.toStringAsFixed(2)}',
                    Icons.speed,
                  ),
                  _buildMetricRow(
                    'Execution time',
                    '${result.executionTimeMs} ms',
                    Icons.timer,
                  ),
                  _buildMetricRow(
                    'Threshold',
                    '${result.thresholdOperationsPerSecond} ops/s',
                    Icons.trending_up,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(child: Text(result.message)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatusBadge(bool passed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: passed
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: passed ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: passed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            passed ? 'PASSED' : 'FAILED',
            style: TextStyle(
              color: passed ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
