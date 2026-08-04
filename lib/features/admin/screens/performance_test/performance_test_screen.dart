import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/admin/performance_test_service.dart';
import 'package:traqtrace_app/features/admin/screens/performance_test/widgets/performance_test_controls.dart';
import 'package:traqtrace_app/features/admin/screens/performance_test/widgets/performance_test_error_view.dart';
import 'package:traqtrace_app/features/admin/screens/performance_test/widgets/performance_test_results.dart';

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
    _testService ??= getIt<PerformanceTestService>();
  }

  Future<void> _runAllTests() async {
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
    if (_testService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final frontendGS1Test =
          await _testService!.runFrontendGS1ValidationPerformanceTest();
      final frontendBarcodeTest =
          await _testService!.runFrontendBarcodeParsingPerformanceTest();

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
    final primaryColor = context.colors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Tests'),
        backgroundColor: primaryColor,
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLoadingIndicator(),
                  SizedBox(height: 16),
                  Text('Running performance tests...'),
                ],
              ),
            )
          : _errorMessage != null
              ? PerformanceTestErrorView(
                  message: _errorMessage!,
                  onRetry: _runAllTests,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PerformanceTestControls(
                        onRunAllBackend: _runAllTests,
                        onRunFrontend: _runFrontendTests,
                        singleTestsEnabled: _testService != null,
                        onRunGs1Validation: () => _runSingleTest(
                          'gs1Validation',
                          _testService!.runGS1ValidationPerformanceTest,
                        ),
                        onRunBatchInsertion: () => _runSingleTest(
                          'batchInsertion',
                          _testService!.runBatchInsertionPerformanceTest,
                        ),
                        onRunQueryCaching: () => _runSingleTest(
                          'queryCaching',
                          _testService!.runQueryCachingPerformanceTest,
                        ),
                        onRunBarcodeParsing: () => _runSingleTest(
                          'barcodeParsing',
                          _testService!.runBarcodeParsingPerformanceTest,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PerformanceTestResults(results: _allTestResults),
                    ],
                  ),
                ),
    );
  }
}
