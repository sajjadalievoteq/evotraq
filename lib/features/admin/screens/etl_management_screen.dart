import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/admin/widgets/etl_management_panel.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

/// ETL Management Screen for Phase 3.3 Batch Processing Capabilities
/// Provides comprehensive ETL pipeline management and monitoring interface
class ETLManagementScreen extends StatelessWidget {
  const ETLManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final appConfig = Provider.of<AppConfig>(context, listen: false);
        final tokenManager = Provider.of<TokenManager>(context, listen: false);
        final baseUrl = appConfig.apiBaseUrl;

        return Scaffold(
          appBar: AppBar(
            title: const Text('ETL Management'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => _showHelpDialog(context),
                tooltip: 'Help',
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.transform,
                                    color: Colors.purple.shade700,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ETL Management',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Extract, Transform, and Load pipeline management with data quality monitoring',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Phase 3.3',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Main Content
                    Expanded(
                      child: ETLManagementPanel(
                        baseUrl: baseUrl,
                        tokenManager: tokenManager,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.purple),
            SizedBox(width: 8),
            Text('ETL Management Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ETL Management Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Pipelines: Create and manage data transformation pipelines'),
              Text('• Transformations: Configure validation, enrichment, and normalization rules'),
              Text('• Execution History: Review pipeline runs and performance metrics'),
              Text('• Quality Metrics: Monitor data completeness, accuracy, and consistency'),
              Text('• Performance Analytics: Track throughput and resource utilization'),
              SizedBox(height: 12),
              Text(
                'Pipeline Management:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Create new ETL pipelines with custom transformation steps'),
              Text('• Schedule automatic pipeline execution'),
              Text('• Monitor active pipeline runs with real-time progress'),
              Text('• Configure pipeline parameters and data sources'),
              SizedBox(height: 12),
              Text(
                'Data Quality Monitoring:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Completeness: Track missing or null data fields'),
              Text('• Accuracy: Validate data against business rules'),
              Text('• Consistency: Check data format and type compliance'),
              Text('• Validity: Ensure data meets defined constraints'),
              SizedBox(height: 12),
              Text(
                'Transformation Types:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• VALIDATION: Data integrity and format checks'),
              Text('• ENRICHMENT: Data enhancement and augmentation'),
              Text('• NORMALIZATION: Data standardization and cleanup'),
              Text('• AGGREGATION: Data summarization and rollup operations'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
