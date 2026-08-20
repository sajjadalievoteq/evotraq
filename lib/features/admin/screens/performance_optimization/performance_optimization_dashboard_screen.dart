import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/services/admin/performance_optimization_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_overview_tab.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_query_optimization_tab.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_connection_pool_tab.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_thread_management_tab.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_resource_management_tab.dart';

import 'package:traqtrace_app/features/admin/screens/performance_optimization/performance_dashboard_actions.dart';

class PerformanceOptimizationDashboard extends StatefulWidget {
  const PerformanceOptimizationDashboard({super.key});

  @override
  State<PerformanceOptimizationDashboard> createState() =>
      PerformanceOptimizationDashboardState();
}

class PerformanceOptimizationDashboardState
    extends State<PerformanceOptimizationDashboard>
    with SingleTickerProviderStateMixin {
  final PerformanceOptimizationService performanceService =
      getIt<PerformanceOptimizationService>();

  late TabController _tabController;
  LoadState<Map<String, dynamic>> reportState = const LoadState.loading();
  bool reportLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ensureTabLoaded(_tabController.index);
      }
    });
    ensureTabLoaded(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Optimization Dashboard'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: refreshPerformanceData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: TraqIcon(NavIcons.dashboard), text: 'Overview'),
            Tab(
              icon: TraqIcon(AppAssets.iconBarChart),
              text: 'Query Optimization',
            ),
            Tab(icon: TraqIcon(AppAssets.iconHub), text: 'Connection Pool'),
            Tab(
              icon: TraqIcon(AppAssets.iconSettings),
              text: 'Thread Management',
            ),
            Tab(
              icon: TraqIcon(AppAssets.iconRefresh),
              text: 'Resource Management',
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveTabView(
            child: PerfOptOverviewTab(
              reportState: reportState,
              onRetry: refreshPerformanceData,
              onRunBenchmark: () => runBenchmark('comprehensive'),
              onDetectSlowQueries: detectSlowQueries,
              onOptimizeMemory: optimizeMemory,
              onDetectLeaks: detectConnectionLeaks,
            ),
          ),
          KeepAliveTabView(
            child: PerfOptQueryOptimizationTab(
              reportState: reportState,
              onRetry: refreshPerformanceData,
              onAnalyzeQuery: analyzeQuery,
              onDetectSlowQueries: detectSlowQueries,
              onAnalyzeTableIndexes: analyzeTableIndexes,
            ),
          ),
          KeepAliveTabView(
            child: PerfOptConnectionPoolTab(
              reportState: reportState,
              onRetry: refreshPerformanceData,
              onOptimizePool: showConnectionPoolOptimization,
              onDetectLeaks: detectConnectionLeaks,
            ),
          ),
          KeepAliveTabView(
            child: PerfOptThreadManagementTab(
              reportState: reportState,
              onRetry: refreshPerformanceData,
              onConfigureThreadPool: configureThreadPool,
            ),
          ),
          KeepAliveTabView(
            child: PerfOptResourceManagementTab(
              reportState: reportState,
              onRetry: refreshPerformanceData,
              onOptimizeMemory: optimizeMemory,
              onOptimizeCpu: optimizeCpu,
              onOptimizeIo: optimizeIo,
            ),
          ),
        ],
      ),
    );
  }
}
