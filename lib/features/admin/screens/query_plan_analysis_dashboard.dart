import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/data/services/advanced_performance_service.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class QueryPlanAnalysisDashboard extends StatefulWidget {
  const QueryPlanAnalysisDashboard({Key? key}) : super(key: key);

  @override
  _QueryPlanAnalysisDashboardState createState() =>
      _QueryPlanAnalysisDashboardState();
}

class _QueryPlanAnalysisDashboardState
    extends State<QueryPlanAnalysisDashboard> {
  late AdvancedPerformanceService _performanceService;
  final TextEditingController _queryController = TextEditingController();
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _recommendations;
  List<dynamic>? _problematicQueries;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadProblematicQueries();
  }

  void _initializeService() {
    final appConfig = getIt<AppConfig>();
    _performanceService = AdvancedPerformanceService(
      dioService: getIt<DioService>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: appConfig,
    );
  }

  Future<void> _loadProblematicQueries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final problematic = await _performanceService.getProblematicQueries();
      setState(() {
        _problematicQueries = problematic;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load problematic queries: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeQuery() async {
    if (_queryController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a SQL query to analyze');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
      _recommendations = null;
    });

    try {
      final analysis = await _performanceService.analyzeQuery(
        _queryController.text,
      );

      final recommendations = await _performanceService
          .getOptimizationRecommendations();

      setState(() {
        _analysisResult = analysis;
        _recommendations = {'recommendations': recommendations};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Query analysis failed: $e';
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Plan Analysis'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _loadProblematicQueries,
            tooltip: 'Refresh Problematic Queries',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SQL Query Analysis',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _queryController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Enter SQL Query',
                        hintText:
                            'SELECT * FROM products WHERE category = \'pharmaceutical\';',
                        border: OutlineInputBorder(),
                        helperText:
                            'Enter a SQL query to analyze its execution plan',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _analyzeQuery,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const TraqIcon(AppAssets.iconBarChart),
                          label: Text(
                            _isLoading ? 'Analyzing...' : 'Analyze Query',
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () {
                            _queryController.clear();
                            setState(() {
                              _analysisResult = null;
                              _recommendations = null;
                              _errorMessage = null;
                            });
                          },
                          icon: TraqIcon(AppAssets.iconX),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      TraqIcon(AppAssets.iconAlert, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(
                          icon: TraqIcon(AppAssets.iconBarChart),
                          text: 'Analysis Results',
                        ),
                        Tab(
                          icon: TraqIcon(AppAssets.iconLightbulb),
                          text: 'Recommendations',
                        ),
                        Tab(
                          icon: TraqIcon(AppAssets.iconAlert),
                          text: 'Problematic Queries',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildAnalysisResultsTab(),

                          _buildRecommendationsTab(),

                          _buildProblematicQueriesTab(),
                        ],
                      ),
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

  Widget _buildAnalysisResultsTab() {
    if (_analysisResult == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraqIcon(AppAssets.iconBarChart, color: Colors.grey, size: 64),
            SizedBox(height: 16),
            Text(
              'No analysis results yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Enter a SQL query and click "Analyze Query" to see results',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Query Execution Plan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAnalysisMetrics(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detailed Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _analysisResult.toString(),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _analysisResult.toString()),
                          );
                          context.showSuccess('Analysis results copied to clipboard');
                        },
                        icon: const TraqIcon(AppAssets.iconCopy),
                        label: const Text('Copy Results'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisMetrics() {
    final executionTime = _analysisResult?['executionTime'] ?? 'N/A';
    final complexity = _analysisResult?['complexityScore'] ?? 'N/A';
    final nodeCount = _analysisResult?['nodeCount'] ?? 'N/A';
    final cost = _analysisResult?['totalCost'] ?? 'N/A';

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Execution Time',
            executionTime.toString(),
            AppAssets.iconTimer,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Complexity',
            complexity.toString(),
            AppAssets.iconTrendingUp,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Node Count',
            nodeCount.toString(),
            AppAssets.iconHierarchy,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Total Cost',
            cost.toString(),
            AppAssets.iconMonetization,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String iconAsset,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TraqIcon(iconAsset, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    if (_recommendations == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraqIcon(AppAssets.iconLightbulb, color: Colors.grey, size: 64),
            SizedBox(height: 16),
            Text(
              'No recommendations available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Analyze a query first to get optimization recommendations',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(AppAssets.iconLightbulb, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Optimization Recommendations',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_recommendations.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblematicQueriesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_problematicQueries == null || _problematicQueries!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraqIcon(AppAssets.iconCheck, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No problematic queries detected',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 8),
            Text(
              'Your queries are performing well!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _problematicQueries!.length,
      itemBuilder: (context, index) {
        final query = _problematicQueries![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: TraqIcon(AppAssets.iconAlert, color: Colors.red),
            ),
            title: Text('Problematic Pattern #${index + 1}'),
            subtitle: Text(query.toString()),
            trailing: IconButton(
              icon: TraqIcon(AppAssets.iconInfo),
              onPressed: () {
                _showQueryDetailsDialog(query);
              },
            ),
          ),
        );
      },
    );
  }

  void _showQueryDetailsDialog(dynamic query) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Query Details'),
          content: SingleChildScrollView(child: Text(query.toString())),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }}
