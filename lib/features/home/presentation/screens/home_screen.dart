import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/services/dashboard_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/home/presentation/screens/home_loading_screen.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/dashboard_health_status_row.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/dashboard_quick_action_card.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/dashboard_recent_event_tile.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/dashboard_stat_card.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/dashboard_welcome_card.dart';

class _HomeDashboardCache {
  static DashboardStats? stats;
  static List<RecentEvent>? recentEvents;
  static SystemHealthStatus? healthStatus;
  static String? ownerEmail;

  static bool get hasData =>
      stats != null && recentEvents != null && healthStatus != null;

  static void clear() {
    stats = null;
    recentEvents = null;
    healthStatus = null;
    ownerEmail = null;
  }

  static void setData({
    required DashboardStats stats,
    required List<RecentEvent> recentEvents,
    required SystemHealthStatus healthStatus,
    required String? ownerEmail,
  }) {
    _HomeDashboardCache.stats = stats;
    _HomeDashboardCache.recentEvents = recentEvents;
    _HomeDashboardCache.healthStatus = healthStatus;
    _HomeDashboardCache.ownerEmail = ownerEmail;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DashboardService _dashboardService;
  DashboardStats? _stats;
  List<RecentEvent>? _recentEvents;
  SystemHealthStatus? _healthStatus;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthCubit>().state.user;
    if (currentUser != null &&
        _HomeDashboardCache.ownerEmail != null &&
        _HomeDashboardCache.ownerEmail != currentUser.email) {
      _HomeDashboardCache.clear();
    }
    if (currentUser == null) {
      context.read<AuthCubit>().getCurrentUser();
    }
    _initializeService();
  }

  void _initializeService() {
    _dashboardService = getIt<DashboardService>();

    if (_HomeDashboardCache.hasData) {
      _stats = _HomeDashboardCache.stats;
      _recentEvents = _HomeDashboardCache.recentEvents;
      _healthStatus = _HomeDashboardCache.healthStatus;
      _isLoading = false;
      _error = null;
      return;
    }

    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _dashboardService.getDashboardStats(),
        _dashboardService.getRecentEvents(limit: 5),
        _dashboardService.getSystemHealth(),
      ]);

      final stats = results[0] as DashboardStats;
      final recentEvents = results[1] as List<RecentEvent>;
      final healthStatus = results[2] as SystemHealthStatus;

      _HomeDashboardCache.setData(
        stats: stats,
        recentEvents: recentEvents,
        healthStatus: healthStatus,
        ownerEmail: context.read<AuthCubit>().state.user?.email,
      );

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _recentEvents = recentEvents;
        _healthStatus = healthStatus;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadDashboardData,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _HomeDashboardCache.clear();
                  context.read<AuthCubit>().logout();
                  context.go(Constants.loginRoute);
                },
                tooltip: 'Logout',
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: _isLoading
                ? const DashboardLoader()
                : _error != null
                    ? _buildErrorState()
                    : _buildDashboard(user),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Failed to load dashboard: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(dynamic user) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 600 ? 12.0 : 16.0;
        final verticalSpacing = constraints.maxWidth < 600 ? 16.0 : 24.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardWelcomeCard(user: user),
              SizedBox(height: verticalSpacing),
              const Text(
                'Statistics Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildStatisticsRow(),
              SizedBox(height: verticalSpacing),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(),
              SizedBox(height: verticalSpacing),
              LayoutBuilder(
                builder: (context, innerConstraints) {
                  if (innerConstraints.maxWidth > Constants.maxContentWidth) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildRecentEventsCard()),
                        const SizedBox(width: 16),
                        Expanded(flex: 1, child: _buildSystemHealthCard()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildRecentEventsCard(),
                      const SizedBox(height: 16),
                      _buildSystemHealthCard(),
                    ],
                  );
                },
              ),
              SizedBox(height: verticalSpacing),
              const Text(
                'Events Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildEventsBarChart(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsRow() {
    final eventCounts = _stats?.eventsByType ?? {};

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth;
        if (constraints.maxWidth < 400) {
          cardWidth = (constraints.maxWidth - 12) / 2;
        } else if (constraints.maxWidth < 600) {
          cardWidth = (constraints.maxWidth - 24) / 3;
        } else if (constraints.maxWidth < 900) {
          cardWidth = (constraints.maxWidth - 36) / 4;
        } else {
          cardWidth = (constraints.maxWidth - 48) / 5;
        }
        cardWidth = cardWidth.clamp(100.0, 160.0);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            DashboardStatCard(
              title: 'GTINs',
              value: _stats?.gtinCount.toString() ?? '0',
              icon: Icons.qr_code,
              color: context.colors.statTileIcon,
              width: cardWidth,
              onTap: () => context.push(Constants.gs1GtinsRoute),
            ),
            DashboardStatCard(
              title: 'GLNs',
              value: _stats?.glnCount.toString() ?? '0',
              icon: Icons.location_on,
              color: context.colors.statTileIcon,
              width: cardWidth,
              onTap: () => context.push(Constants.gs1GlnsRoute),
            ),
            DashboardStatCard(
              title: 'SGTINs',
              value: _stats?.sgtinCount.toString() ?? '0',
              icon: Icons.qr_code_scanner,
              color: context.colors.statTileIcon,
              width: cardWidth,
              onTap: () => context.push(Constants.gs1SgtinsRoute),
            ),
            DashboardStatCard(
              title: 'SSCCs',
              value: _stats?.ssccCount.toString() ?? '0',
              icon: Icons.inventory,
              color: context.colors.statTileIcon,
              width: cardWidth,
              onTap: () => context.push(Constants.gs1SsccsRoute),
            ),
            DashboardStatCard(
              title: 'Object',
              value: (eventCounts['Object'] ?? 0).toString(),
              icon: Icons.inventory_2,
              color: context.colors.statTileIcon,
              width: cardWidth,
              onTap: () => context.push(Constants.epcisObjectEventsRoute),
            ),
            DashboardStatCard(
              title: 'Aggregation',
              value: (eventCounts['Aggregation'] ?? 0).toString(),
              icon: Icons.category,
              color: context.colors.statTileIcon,
              width: cardWidth,
              onTap: () => context.push(Constants.epcisAggregationEventsRoute),
            ),
            DashboardStatCard(
              title: 'Transaction',
              value: (eventCounts['Transaction'] ?? 0).toString(),
              icon: Icons.receipt,
              color: context.colors.statTileIcon,
              width: cardWidth,
              onTap: () => context.push(Constants.epcisTransactionEventsRoute),
            ),
            DashboardStatCard(
              title: 'Transform',
              value: (eventCounts['Transformation'] ?? 0).toString(),
              icon: Icons.transform,
              color: context.colors.statTileIcon,
              width: cardWidth,
              onTap: () =>
                  context.push(Constants.epcisTransformationEventsRoute),
            ),
            DashboardStatCard(
              title: 'Total',
              value: _stats?.totalEvents.toString() ?? '0',
              icon: Icons.event,
              color: context.colors.statTileIcon,
              width: cardWidth,
              onTap: () => context.push(Constants.epcisEventsRoute),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      const DashboardQuickAction(
        icon: Icons.qr_code,
        title: 'GTIN Management',
        subtitle: 'GS1 identifiers',
        color: Colors.blue,
        route: Constants.gs1GtinsRoute,
        isDisabled: false,
      ),
      const DashboardQuickAction(
        icon: Icons.location_on,
        title: 'GLN Management',
        color: Colors.green,
        route: Constants.gs1GlnsRoute,
      ),
      const DashboardQuickAction(
        icon: Icons.qr_code_scanner,
        title: 'SGTIN Management',
        color: Colors.orange,
        route: Constants.gs1SgtinsRoute,
      ),
      const DashboardQuickAction(
        icon: Icons.inventory,
        title: 'SSCC Management',
        color: Colors.purple,
        route: Constants.gs1SsccsRoute,
      ),
      const DashboardQuickAction(
        icon: Icons.local_shipping,
        title: 'Create Shipment',
        color: Colors.indigo,
        route: Constants.opShippingCreateRoute,
      ),
      const DashboardQuickAction(
        icon: Icons.download,
        title: 'Receive Shipment',
        color: Colors.teal,
        route: Constants.opReceivingRoute,
      ),
      const DashboardQuickAction(
        icon: Icons.inventory_2,
        title: 'Packing',
        color: Colors.deepOrange,
        route: Constants.opPackingRoute,
      ),
      const DashboardQuickAction(
        icon: Icons.play_for_work,
        title: 'Commissioning',
        color: Colors.cyan,
        route: Constants.opCommissioningRoute,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        if (constraints.maxWidth < 360) {
          crossAxisCount = 2;
          childAspectRatio = 0.9;
        } else if (constraints.maxWidth < 500) {
          crossAxisCount = 2;
          childAspectRatio = 1.0;
        } else if (constraints.maxWidth < 700) {
          crossAxisCount = 3;
          childAspectRatio = 1.0;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 4;
          childAspectRatio = 1.1;
        } else {
          crossAxisCount = 6;
          childAspectRatio = 1.1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return DashboardQuickActionCard(action: action);
          },
        );
      },
    );
  }

  Widget _buildRecentEventsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(Constants.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Events',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push(Constants.epcisEventsRoute),
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            if (_recentEvents == null || _recentEvents!.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No recent events',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...(_recentEvents!.map(
                (event) => DashboardRecentEventTile(event: event),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealthCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(Constants.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Health',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            DashboardHealthStatusRow(
              title: 'Backend API',
              isHealthy: _healthStatus?.backendHealthy ?? false,
            ),
            DashboardHealthStatusRow(
              title: 'Database',
              isHealthy: _healthStatus?.databaseHealthy ?? false,
            ),
            DashboardHealthStatusRow(
              title: 'Cache',
              isHealthy: _healthStatus?.cacheHealthy ?? false,
            ),
            if (_healthStatus?.backendVersion != null) ...[
              const Divider(),
              Text(
                'Version: ${_healthStatus!.backendVersion}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventsBarChart() {
    final eventCounts = _stats?.eventsByType ?? {};

    if (eventCounts.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No event data available',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final entries = eventCounts.entries.toList();
    final calculatedMaxY =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;
    final maxY = calculatedMaxY > 0 ? calculatedMaxY.toDouble() : 10.0;

    final barColors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 400;
            final barWidth = isSmallScreen ? 20.0 : 40.0;
            final chartHeight = isSmallScreen ? 220.0 : 300.0;

            return SizedBox(
              height: chartHeight,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${entries[groupIndex].key}\n${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < entries.length) {
                            String label = entries[index].key;
                            if (label.contains(' ')) {
                              label = label.split(' ').first;
                            }
                            if (isSmallScreen && label.length > 4) {
                              label = label.substring(0, 3);
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 8 : 10,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isSmallScreen ? 30 : 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: isSmallScreen ? 8 : 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.value.toDouble(),
                          color: barColors[index % barColors.length],
                          width: barWidth,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

