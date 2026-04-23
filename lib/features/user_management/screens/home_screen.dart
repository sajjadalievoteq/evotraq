import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/data/services/dashboard_service.dart';
import 'package:traqtrace_app/features/user_management/screens/home_loading_screen.dart';

import 'package:traqtrace_app/core/consts/app_consts.dart';

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
  const HomeScreen({Key? key}) : super(key: key);

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
                ?

            DashboardLoader()
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
        // Responsive padding: smaller on mobile
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
              // Welcome Section
              _WelcomeCard(user: user),
              SizedBox(height: verticalSpacing),

              // Statistics Cards Row
              const Text(
                'Statistics Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildStatisticsRow(),
              SizedBox(height: verticalSpacing),

              // Quick Actions Grid
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(),
              SizedBox(height: verticalSpacing),

              // Two-column layout for Recent Events and System Health
              LayoutBuilder(
                builder: (context, innerConstraints) {
                  if (innerConstraints.maxWidth > Constants.maxContentWidth) {
                    // Wide screen - side by side
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildRecentEventsCard()),
                        const SizedBox(width: 16),
                        Expanded(flex: 1, child: _buildSystemHealthCard()),
                      ],
                    );
                  } else {
                    // Narrow screen - stacked
                    return Column(
                      children: [
                        _buildRecentEventsCard(),
                        const SizedBox(height: 16),
                        _buildSystemHealthCard(),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: verticalSpacing),

              // Events Bar Chart
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
        // Calculate card width based on screen size
        // On mobile (< 600px): 2 cards per row
        // On tablet (600-900px): 3 cards per row
        // On desktop (> 900px): 4-5 cards per row
        double cardWidth;
        if (constraints.maxWidth < 400) {
          cardWidth = (constraints.maxWidth - 12) / 2; // 2 cards
        } else if (constraints.maxWidth < 600) {
          cardWidth = (constraints.maxWidth - 24) / 3; // 3 cards
        } else if (constraints.maxWidth < 900) {
          cardWidth = (constraints.maxWidth - 36) / 4; // 4 cards
        } else {
          cardWidth = (constraints.maxWidth - 48) / 5; // 5 cards
        }
        cardWidth = cardWidth.clamp(100.0, 160.0);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(
              title: 'GTINs',
              value: _stats?.gtinCount.toString() ?? '0',
              icon: Icons.qr_code,
              color: AppTheme.statsTiles, //Colors.blue,
              width: cardWidth,
              onTap: () => context.push(Constants.gs1GtinsRoute),
            ),
            _StatCard(
              title: 'GLNs',
              value: _stats?.glnCount.toString() ?? '0',
              icon: Icons.location_on,
              color: AppTheme.statsTiles,
              width: cardWidth,
              onTap: () => context.push(Constants.gs1GlnsRoute),
            ),
            _StatCard(
              title: 'SGTINs',
              value: _stats?.sgtinCount.toString() ?? '0',
              icon: Icons.qr_code_scanner,
              color: AppTheme.statsTiles,
              width: cardWidth,
              onTap: () => context.push(Constants.gs1SgtinsRoute),
            ),
            _StatCard(
              title: 'SSCCs',
              value: _stats?.ssccCount.toString() ?? '0',
              icon: Icons.inventory,
              color: AppTheme.statsTiles,
              width: cardWidth,
              onTap: () => context.push(Constants.gs1SsccsRoute),
            ),
            // Event type counts
            _StatCard(
              title: 'Object',
              value: (eventCounts['Object'] ?? 0).toString(),
              icon: Icons.inventory_2,
              color: AppTheme.statsTiles,
              width: cardWidth,
              onTap: () => context.push(Constants.epcisObjectEventsRoute),
            ),
            _StatCard(
              title: 'Aggregation',
              value: (eventCounts['Aggregation'] ?? 0).toString(),
              icon: Icons.category,
              color: AppTheme.statsTiles,
              width: cardWidth,
              onTap: () => context.push(Constants.epcisAggregationEventsRoute),
            ),
            _StatCard(
              title: 'Transaction',
              value: (eventCounts['Transaction'] ?? 0).toString(),
              icon: Icons.receipt,
              color: AppTheme.statsTiles,
              width: cardWidth,
              onTap: () => context.push(Constants.epcisTransactionEventsRoute),
            ),
            _StatCard(
              title: 'Transform',
              value: (eventCounts['Transformation'] ?? 0).toString(),
              icon: Icons.transform,
              color: AppTheme.statsTiles,
              width: cardWidth,
              onTap: () => context.push(Constants.epcisTransformationEventsRoute),
            ),
            _StatCard(
              title: 'Total',
              value: _stats?.totalEvents.toString() ?? '0',
              icon: Icons.event,
              color: AppTheme.statsTiles,
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
      _QuickAction(
        icon: Icons.qr_code,
        title: 'GTIN Management',
        subtitle: 'GS1 identifiers',
        color: Colors.blue,
        route: Constants.gs1GtinsRoute,
        isDisabled: false,
      ),
      _QuickAction(
        icon: Icons.location_on,
        title: 'GLN Management',
        color: Colors.green,
        route: Constants.gs1GlnsRoute,
      ),
      _QuickAction(
        icon: Icons.qr_code_scanner,
        title: 'SGTIN Management',
        color: Colors.orange,
        route: Constants.gs1SgtinsRoute,
      ),
      _QuickAction(
        icon: Icons.inventory,
        title: 'SSCC Management',
        color: Colors.purple,
        route: Constants.gs1SsccsRoute,
      ),
      _QuickAction(
        icon: Icons.local_shipping,
        title: 'Create Shipment',
        color: Colors.indigo,
        route: Constants.opShippingCreateRoute,
      ),
      _QuickAction(
        icon: Icons.download,
        title: 'Receive Shipment',
        color: Colors.teal,
        route: Constants.opReceivingRoute,
      ),
      _QuickAction(
        icon: Icons.inventory_2,
        title: 'Packing',
        color: Colors.deepOrange,
        route: Constants.opPackingRoute,
      ),
      _QuickAction(
        icon: Icons.play_for_work,
        title: 'Commissioning',
        color: Colors.cyan,
        route: Constants.opCommissioningRoute,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: 2 columns on mobile, 3 on tablet, 4+ on desktop
        // Adjusted aspect ratios to prevent overflow
        int crossAxisCount;
        double childAspectRatio;
        if (constraints.maxWidth < 360) {
          crossAxisCount = 2;
          childAspectRatio = 0.9; // Taller cards for small screens
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
            return _QuickActionCard(action: action);
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
                (event) => _RecentEventTile(event: event),
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
            _HealthStatusRow(
              title: 'Backend API',
              isHealthy: _healthStatus?.backendHealthy ?? false,
            ),
            _HealthStatusRow(
              title: 'Database',
              isHealthy: _healthStatus?.databaseHealthy ?? false,
            ),
            _HealthStatusRow(
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
    // Ensure maxY is never 0 to avoid division by zero in horizontalInterval
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
                            // Shorten labels for display
                            String label = entries[index].key;
                            if (label.contains(' ')) {
                              label = label.split(' ').first;
                            }
                            // Further shorten on small screens
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

// Widgets

class _WelcomeCard extends StatelessWidget {
  final dynamic user;

  const _WelcomeCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String greeting;

    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, ${user.firstName}!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 18 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSmallScreen
                            ? 'Manage your supply chain.'
                            : 'Welcome to evotraq.io. Manage your supply chain with GS1 compliance.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSmallScreen) ...[
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width ?? 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final String? route;
  final bool isDisabled;

  _QuickAction({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.route,
    this.isDisabled = false,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: action.isDisabled ? 0 : 2,
      color: action.isDisabled ? Colors.grey[100] : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: action.isDisabled || action.route == null
            ? null
            : () => context.push(action.route!),
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adjust sizes based on available space
            final isCompact = constraints.maxHeight < 120;
            final iconSize = isCompact ? 22.0 : 28.0;
            final iconPadding = isCompact ? 8.0 : 12.0;
            final fontSize = isCompact ? 11.0 : 13.0;
            final spacing = isCompact ? 6.0 : 12.0;
            final padding = isCompact ? 8.0 : 16.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: action.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action.icon,
                        size: iconSize,
                        color: action.color,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Flexible(
                    child: Text(
                      action.title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: action.isDisabled ? Colors.grey : null,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (action.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      action.subtitle!,
                      style: TextStyle(
                        fontSize: isCompact ? 8 : 10,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecentEventTile extends StatelessWidget {
  final RecentEvent event;

  const _RecentEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(event.eventTime);

    IconData eventIcon;
    Color eventColor;

    switch (event.eventType.toLowerCase()) {
      case 'objectevent':
        eventIcon = Icons.inventory_2;
        eventColor = Colors.blue;
        break;
      case 'aggregationevent':
        eventIcon = Icons.category;
        eventColor = Colors.green;
        break;
      case 'transactionevent':
        eventIcon = Icons.receipt;
        eventColor = Colors.orange;
        break;
      case 'transformationevent':
        eventIcon = Icons.transform;
        eventColor = Colors.purple;
        break;
      default:
        eventIcon = Icons.event;
        eventColor = Colors.grey;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: eventColor.withOpacity(0.1),
        child: Icon(eventIcon, color: eventColor, size: 20),
      ),
      title: Text(
        event.eventType,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        event.action.isNotEmpty
            ? event.action
            : (event.bizStep ?? 'No details'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        timeAgo,
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _HealthStatusRow extends StatelessWidget {
  final String title;
  final bool isHealthy;

  const _HealthStatusRow({required this.title, required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHealthy ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            isHealthy ? 'Healthy' : 'Unhealthy',
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
