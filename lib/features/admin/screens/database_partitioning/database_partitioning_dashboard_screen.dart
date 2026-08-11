import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/models/partition_models.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/services/admin/database_partitioning_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_overview_content.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_details_tab.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_archive_tab.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_maintenance_tab.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/help_widgets/partition_help_section.dart';

part 'database_partitioning_actions.dart';

class _OverviewData {
  final PartitionStatistics statistics;
  final Map<String, dynamic> health;

  const _OverviewData(this.statistics, this.health);
}

class DatabasePartitioningDashboard extends StatefulWidget {
  const DatabasePartitioningDashboard({Key? key}) : super(key: key);

  @override
  State<DatabasePartitioningDashboard> createState() =>
      _DatabasePartitioningDashboardState();
}

class _DatabasePartitioningDashboardState
    extends State<DatabasePartitioningDashboard>
    with TickerProviderStateMixin {
  late final DatabasePartitioningService _partitioningService;
  late TabController _tabController;

  final Set<int> _loadedTabs = {};

  LoadState<_OverviewData> _overviewState = const LoadState.loading();

  LoadState<List<PartitionMetadata>> _metadataState = const LoadState.loading();

  final List<String> _validTables = [
    'epcis_events',
    'object_events',
    'aggregation_events',
    'transaction_events',
    'transformation_events',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _ensureTabLoaded(_tabController.index);
      }
    });

    _partitioningService = getIt<DatabasePartitioningService>();

    _ensureTabLoaded(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _ensureTabLoaded(int index) {
    if (_loadedTabs.contains(index)) return;
    _loadedTabs.add(index);

    switch (index) {
      case 0:
        _loadOverview();
        break;
      case 1:
        _loadOverview();
        _loadMetadata();
        break;
      default:
        break;
    }
  }

  Future<void> _loadOverview({bool force = false}) async {
    if (!force && _overviewState.isSuccess) return;

    setState(() {
      _overviewState = const LoadState.loading();
    });

    try {
      final overview = await _partitioningService.getDashboardOverview();
      final statsJson = overview['statistics'];
      final healthJson = overview['health'];

      if (!mounted) return;

      if (statsJson == null) {
        setState(() {
          _overviewState = const LoadState.empty();
        });
        return;
      }

      final statistics = PartitionStatistics.fromJson(
        (statsJson as Map).cast<String, dynamic>(),
      );
      final health = healthJson != null
          ? (healthJson as Map).cast<String, dynamic>()
          : <String, dynamic>{};

      setState(() {
        _overviewState = LoadState.success(_OverviewData(statistics, health));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _overviewState = LoadState.error(e.toString());
      });
    }
  }

  Future<void> _loadMetadata({bool force = false}) async {
    if (!force && _metadataState.isSuccess) return;

    setState(() {
      _metadataState = const LoadState.loading();
    });

    try {
      final metadata = await _partitioningService.getPartitionMetadata();

      if (!mounted) return;
      setState(() {
        _metadataState = metadata.isEmpty
            ? const LoadState.empty()
            : LoadState.success(metadata);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _metadataState = LoadState.error(e.toString());
      });
    }
  }

  Future<void> _refreshLoadedTabs() async {
    final futures = <Future<void>>[];

    if (_loadedTabs.contains(0) || _loadedTabs.contains(1)) {
      futures.add(_loadOverview(force: true));
    }
    if (_loadedTabs.contains(1)) {
      futures.add(_loadMetadata(force: true));
    }

    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Database Table Partitions Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: TraqIcon(NavIcons.dashboard)),
            Tab(text: 'Partitions', icon: TraqIcon(AppAssets.iconTable)),
            Tab(text: 'Archive', icon: TraqIcon(AppAssets.iconDownload)),
            Tab(text: 'Maintenance', icon: TraqIcon(AppAssets.iconSettings)),
          ],
        ),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconInfo),
            onPressed: _showHelpDialog,
            tooltip: 'Help & Information',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _refreshLoadedTabs,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveTabView(
            child: LoadStateView<_OverviewData>(
              state: _overviewState,
              onRetry: () => _loadOverview(force: true),
              builder: (context, data) => PartitionOverviewContent(
                statistics: data.statistics,
                health: data.health,
              ),
            ),
          ),
          KeepAliveTabView(
            child: PartitionDetailsTab<_OverviewData>(
              overviewState: _overviewState,
              metadataState: _metadataState,
              onRetryOverview: () => _loadOverview(force: true),
              onRetryMetadata: () => _loadMetadata(force: true),
              statisticsOf: (data) => data.statistics,
            ),
          ),
          KeepAliveTabView(child: const PartitionArchiveTab()),
          KeepAliveTabView(
            child: PartitionMaintenanceTab(
              onPerformMaintenance: _performMaintenance,
            ),
          ),
        ],
      ),
    );
  }
}
