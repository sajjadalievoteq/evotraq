import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_management_cubit.dart';
import 'package:traqtrace_app/features/api_management/models/partner.dart';
import 'package:traqtrace_app/features/api_management/models/api_audit.dart';

/// Screen for viewing partner API usage analytics and audit logs
class ApiAnalyticsScreen extends StatefulWidget {
  final String partnerId;

  const ApiAnalyticsScreen({super.key, required this.partnerId});

  @override
  State<ApiAnalyticsScreen> createState() => _ApiAnalyticsScreenState();
}

class _ApiAnalyticsScreenState extends State<ApiAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final cubit = context.read<ApiManagementCubit>();
    cubit.selectPartner(widget.partnerId);
    cubit.loadAuditLogs(
      widget.partnerId,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );
    cubit.loadUsageStats(
      widget.partnerId,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );
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
        title: const Text('API Analytics'),
        actions: [
          TextButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range, color: Colors.white),
            label: Text(
              _dateRange != null
                  ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                  : 'Select Range',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Usage Stats'),
            Tab(icon: Icon(Icons.history), text: 'Audit Logs'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<ApiManagementCubit, ApiManagementState>(
        builder: (context, state) {
          final partner = state.selectedPartner;

          if (state.loading && partner == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (partner == null) {
            return const Center(child: Text('Partner not found'));
          }

          return Column(
            children: [
              _buildPartnerHeader(partner),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUsageStatsTab(state),
                    _buildAuditLogsTab(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPartnerHeader(Partner partner) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Text(
              partner.companyName.isNotEmpty ? partner.companyName[0].toUpperCase() : 'P',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.companyName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  partner.partnerCode,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStatsTab(ApiManagementState state) {
    final stats = state.usageStats;

    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(stats),
          const SizedBox(height: 24),
          _buildSectionHeader('Daily API Calls'),
          const SizedBox(height: 12),
          _buildDailyUsageChart(stats),
          const SizedBox(height: 24),
          _buildSectionHeader('Response Time Distribution'),
          const SizedBox(height: 12),
          _buildResponseTimeInfo(stats),
          const SizedBox(height: 24),
          _buildSectionHeader('Top Endpoints'),
          const SizedBox(height: 12),
          _buildTopEndpoints(stats),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ApiUsageStats stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Requests', stats.totalRequests.toString(), Icons.api, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Successful', '${stats.successRate.toStringAsFixed(1)}%', Icons.check_circle, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Failed', stats.failedRequests.toString(), Icons.error, Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Avg Response', '${stats.avgResponseTime.toStringAsFixed(0)} ms', Icons.timer, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyUsageChart(ApiUsageStats stats) {
    if (stats.dailyUsage.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('No daily usage data available')),
      );
    }

    final maxRequests = stats.dailyUsage.map((d) => d.requestCount).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: stats.dailyUsage.map((daily) {
          final height = maxRequests > 0 
              ? (daily.requestCount / maxRequests) * 160 
              : 0.0;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    daily.requestCount.toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.7),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${daily.date.day}/${daily.date.month}',
                    style: const TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResponseTimeInfo(ApiUsageStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResponseTimeStat('Min', stats.minResponseTime, Colors.green),
                _buildResponseTimeStat('Avg', stats.avgResponseTime, Colors.blue),
                _buildResponseTimeStat('P50', stats.p50ResponseTime, Colors.orange),
                _buildResponseTimeStat('P95', stats.p95ResponseTime, Colors.deepOrange),
                _buildResponseTimeStat('P99', stats.p99ResponseTime, Colors.red),
                _buildResponseTimeStat('Max', stats.maxResponseTime, Colors.red.shade900),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTimeStat(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)} ms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTopEndpoints(ApiUsageStats stats) {
    if (stats.topEndpoints.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No endpoint data available'),
        ),
      );
    }

    return Card(
      child: Column(
        children: stats.topEndpoints.entries.take(5).map((entry) {
          return ListTile(
            leading: const Icon(Icons.arrow_forward),
            title: Text(entry.key),
            trailing: Text(
              '${entry.value} calls',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAuditLogsTab(ApiManagementState state) {
    final logs = state.auditLogs;

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No audit logs found'),
            const SizedBox(height: 8),
            Text(
              'API calls will be logged here',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildAuditLogCard(log);
      },
    );
  }

  Widget _buildAuditLogCard(ApiAuditLog log) {
    final statusColor = log.isSuccess
        ? Colors.green
        : log.isClientError
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getMethodColor(log.httpMethod).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              log.httpMethod,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: _getMethodColor(log.httpMethod),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.endpoint,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                log.httpStatus.toString(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              _formatDateTime(log.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            Text(
              '${log.responseTimeMs} ms',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogDetail('Request ID', log.requestId),
                _buildLogDetail('Client IP', log.clientIp ?? 'Unknown'),
                if (log.userAgent != null)
                  _buildLogDetail('User Agent', log.userAgent!),
                if (log.errorMessage != null)
                  _buildLogDetail('Error', log.errorMessage!, isError: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogDetail(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: isError ? Colors.red : null,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (range != null) {
      setState(() => _dateRange = range);
      _loadData();
    }
  }
}
