import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/features/admin/services/integration_validation_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

class IntegrationValidationScreen extends StatefulWidget {
  const IntegrationValidationScreen({Key? key}) : super(key: key);

  @override
  State<IntegrationValidationScreen> createState() =>
      _IntegrationValidationScreenState();
}

class _IntegrationValidationScreenState
    extends State<IntegrationValidationScreen> {
  IntegrationValidationService? _validationService;
  bool _isLoading = false;
  Map<String, ValidationResultDTO>? _allTestResults;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the service
    _validationService ??= IntegrationValidationService(
      baseUrl: getIt<AppConfig>().apiBaseUrl,
    );
  }

  Future<void> _runAllTests() async {
    // Make sure service is initialized
    if (_validationService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _validationService!.runAllValidationTests();
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
    Future<ValidationResultDTO> Function() testFn,
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode
        ? AppTheme.primaryColorDark
        : AppTheme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Integration Validation'),
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
                  const Text('Running integration validation tests...'),
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
              'Integration Validation Tests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Run integration validation tests to ensure GS1 system compliance and functionality.',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'GS1 Standards Tests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _runAllTests,
                  child: const Text('Run All Tests'),
                ),
                OutlinedButton(
                  onPressed: _validationService == null
                      ? null
                      : () => _runSingleTest(
                          'gs1IdentifierGeneration',
                          _validationService!.validateGS1IdentifierGeneration,
                        ),
                  child: const Text('GS1 Identifier Generation'),
                ),
                OutlinedButton(
                  onPressed: _validationService == null
                      ? null
                      : () => _runSingleTest(
                          'barcodeGenerationReading',
                          _validationService!
                              .validateBarcodeGenerationAndReading,
                        ),
                  child: const Text('Barcode Generation/Reading'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'EPCIS & Data Model Tests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _validationService == null
                      ? null
                      : () => _runSingleTest(
                          'epcisEventCreation',
                          _validationService!.validateEPCISEventCreation,
                        ),
                  child: const Text('EPCIS Event Creation'),
                ),
                OutlinedButton(
                  onPressed: _validationService == null
                      ? null
                      : () => _runSingleTest(
                          'relationshipMapping',
                          _validationService!.validateRelationshipMapping,
                        ),
                  child: const Text('Relationship Mapping'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'API & Error Handling Tests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _validationService == null
                      ? null
                      : () => _runSingleTest(
                          'apiContracts',
                          _validationService!.validateAPIContracts,
                        ),
                  child: const Text('API Contracts'),
                ),
                OutlinedButton(
                  onPressed: _validationService == null
                      ? null
                      : () => _runSingleTest(
                          'errorHandling',
                          _validationService!.testErrorHandling,
                        ),
                  child: const Text('Error Handling'),
                ),
                OutlinedButton(
                  onPressed: _validationService == null
                      ? null
                      : () => _runSingleTest(
                          'responseFormats',
                          _validationService!.validateResponseFormats,
                        ),
                  child: const Text('Response Formats'),
                ),
                OutlinedButton(
                  onPressed: _validationService == null
                      ? null
                      : () => _runSingleTest(
                          'authorizationControls',
                          _validationService!.checkAuthorizationControls,
                        ),
                  child: const Text('Authorization Controls'),
                ),
              ],
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
            const Text('Use the controls above to run integration tests'),
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
          final result = entry.value;

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
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Text(
                          'Integration Test',
                          style: TextStyle(
                            color: Colors.blue[700],
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
                  ..._buildStepsSection(result),
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

  List<Widget> _buildStepsSection(ValidationResultDTO result) {
    final List<Widget> stepWidgets = [];

    stepWidgets.add(
      Row(
        children: [
          Icon(Icons.checklist, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            'Validation Steps',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );

    stepWidgets.add(const SizedBox(height: 12));

    // Add summary
    stepWidgets.add(
      Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 16),
        child: Text(
          'Passed: ${result.passedSteps.length}/${result.validationSteps.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    // Add all steps
    for (final step in result.validationSteps) {
      final bool isPassed = result.passedSteps.contains(step);
      final bool isFailed = result.failedSteps.contains(step);

      stepWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                isPassed
                    ? Icons.check_circle
                    : (isFailed ? Icons.cancel : Icons.circle_outlined),
                size: 18,
                color: isPassed
                    ? Colors.green
                    : (isFailed ? Colors.red : Colors.grey),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(step)),
            ],
          ),
        ),
      );
    }

    return stepWidgets;
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
}
