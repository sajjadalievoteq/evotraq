import 'package:flutter/material.dart';

class SupplyChainVisualizationWidget extends StatefulWidget {
  final Map<String, dynamic>? traversalResult;
  final Map<String, dynamic>? itemHistory;
  final Map<String, dynamic>? aggregationHierarchy;
  final bool isLoading;
  final String? error;

  const SupplyChainVisualizationWidget({
    super.key,
    this.traversalResult,
    this.itemHistory,
    this.aggregationHierarchy,
    this.isLoading = false,
    this.error,
  });

  @override
  State<SupplyChainVisualizationWidget> createState() => _SupplyChainVisualizationWidgetState();
}

class _SupplyChainVisualizationWidgetState extends State<SupplyChainVisualizationWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading visualization...'),
          ],
        ),
      );
    }

    if (widget.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Visualization Error',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.traversalResult == null && 
        widget.itemHistory == null && 
        widget.aggregationHierarchy == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Data to Visualize',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Execute a traversal query to see supply chain visualization here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.route),
              text: 'Supply Chain',
            ),
            Tab(
              icon: Icon(Icons.timeline),
              text: 'Timeline',
            ),
            Tab(
              icon: Icon(Icons.account_tree),
              text: 'Hierarchy',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSupplyChainView(),
              _buildTimelineView(),
              _buildHierarchyView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupplyChainView() {
    if (widget.traversalResult == null) {
      return _buildEmptyState(
        icon: Icons.route,
        title: 'No Supply Chain Data',
        subtitle: 'Execute a Supply Chain Path query to see the visualization.',
      );
    }

    final result = widget.traversalResult!;
    final nodes = result['nodes'] as List<dynamic>? ?? [];
    final edges = result['edges'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            'Supply Chain Path Summary',
            [
              _buildSummaryItem('Total Nodes', nodes.length.toString()),
              _buildSummaryItem('Total Edges', edges.length.toString()),
              _buildSummaryItem('Path Depth', result['maxDepth']?.toString() ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supply Chain Nodes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...nodes.map((node) => _buildNodeCard(node)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    if (widget.itemHistory == null) {
      return _buildEmptyState(
        icon: Icons.timeline,
        title: 'No Timeline Data',
        subtitle: 'Execute an Item History query to see the timeline.',
      );
    }

    final history = widget.itemHistory!;
    final events = history['events'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            'Item History Summary',
            [
              _buildSummaryItem('Total Events', (history['totalEvents'] ?? events.length).toString()),
              _buildSummaryItem('First Event', history['firstEventTime'] != null ? 
                _formatTimestamp(history['firstEventTime']) : 'N/A'),
              _buildSummaryItem('Last Event', history['lastEventTime'] != null ? 
                _formatTimestamp(history['lastEventTime']) : 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Timeline',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...events.asMap().entries.map((entry) => 
                    _buildTimelineItem(entry.value, entry.key == events.length - 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyView() {
    if (widget.aggregationHierarchy == null) {
      return _buildEmptyState(
        icon: Icons.account_tree,
        title: 'No Hierarchy Data',
        subtitle: 'Execute an Aggregation Hierarchy query to see the structure.',
      );
    }

    final hierarchy = widget.aggregationHierarchy!;
    final directChildren = hierarchy['directChildren'] as List<dynamic>? ?? [];
    final hierarchyDepth = hierarchy['hierarchyDepth'] ?? 0;
    final totalItemCount = hierarchy['totalItemCount'] ?? 0;
    
    // Debug the specific values being used in the UI
    print('DEBUG UI VALUES:');
    print('  - directChildren.length: ${directChildren.length}');
    print('  - totalItemCount: $totalItemCount');
    print('  - hierarchyDepth: $hierarchyDepth');
    print('  - parentEpc: ${hierarchy['parentEpc']}');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            'Aggregation Hierarchy Summary',
            [
              _buildSummaryItem('Parent EPC', hierarchy['parentEpc']?.toString() ?? 'N/A'),
              _buildSummaryItem('Direct Children', directChildren.length.toString()),
              _buildSummaryItem('Total Items', totalItemCount.toString()),
              _buildSummaryItem('Hierarchy Depth', hierarchyDepth.toString()),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aggregation Structure',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildHierarchyTree(hierarchy),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<Widget> items) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text for visibility against blue background
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70, // Slightly transparent white for labels
          ),
        ),
      ],
    );
  }

  Widget _buildNodeCard(Map<String, dynamic> node) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNodeColor(node['type']?.toString()),
          child: Icon(
            _getNodeIcon(node['type']?.toString()),
            color: Colors.white,
          ),
        ),
        title: Text(node['epc']?.toString() ?? 'Unknown EPC'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${node['type'] ?? 'Unknown'}'),
            Text('Location: ${node['location'] ?? 'Unknown'}'),
          ],
        ),
        trailing: Text(
          'Depth: ${node['depth'] ?? 0}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> event, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getEventColor(event['eventType']?.toString()),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['eventType']?.toString() ?? 'Unknown Event',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(event['eventTime']),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (event['businessStep'] != null) ...[
                      const SizedBox(height: 4),
                      Text('Business Step: ${event['businessStep']}'),
                    ],
                    if (event['readPoint'] != null) ...[
                      const SizedBox(height: 4),
                      Text('Location: ${event['readPoint']}'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyTree(Map<String, dynamic> hierarchy) {
    final parentEpc = hierarchy['parentEpc']?.toString() ?? 'Unknown EPC';
    final directChildren = hierarchy['directChildren'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Root parent container
        Card(
          margin: const EdgeInsets.symmetric(vertical: 2.0),
          child: ListTile(
            dense: true,
            leading: Icon(
              Icons.inventory_2,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(parentEpc),
            subtitle: Text('Container - ${directChildren.length} direct children'),
            trailing: directChildren.isNotEmpty 
                ? const Icon(Icons.keyboard_arrow_down)
                : null,
          ),
        ),
        // Direct children
        ...directChildren.map((child) => _buildChildItem(child, 1)),
      ],
    );
  }

  Widget _buildChildItem(dynamic childData, int depth) {
    if (childData is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }
    
    final epc = childData['epc']?.toString() ?? 'Unknown EPC';
    final epcType = childData['epcType']?.toString() ?? 'Unknown';
    final hierarchyLevel = childData['hierarchyLevel'] ?? depth - 1;
    final status = childData['status']?.toString() ?? 'Unknown';
    
    return Padding(
      padding: EdgeInsets.only(left: depth * 24.0),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 2.0),
        child: ListTile(
          dense: true,
          leading: Icon(
            _getItemIcon(epcType),
            color: _getStatusColor(status),
          ),
          title: Text(epc),
          subtitle: Text('$epcType - Level $hierarchyLevel'),
          trailing: Text(
            status,
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getItemIcon(String epcType) {
    switch (epcType.toUpperCase()) {
      case 'SSCC':
        return Icons.inventory_2;
      case 'SGTIN':
        return Icons.inventory;
      case 'SGLN':
        return Icons.location_on;
      case 'GRAI':
        return Icons.crop_free;
      case 'GIAI':
        return Icons.badge;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getNodeColor(String? type) {
    switch (type) {
      case 'manufacturer':
        return Colors.blue;
      case 'distributor':
        return Colors.green;
      case 'retailer':
        return Colors.orange;
      case 'warehouse':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNodeIcon(String? type) {
    switch (type) {
      case 'manufacturer':
        return Icons.factory;
      case 'distributor':
        return Icons.local_shipping;
      case 'retailer':
        return Icons.store;
      case 'warehouse':
        return Icons.warehouse;
      default:
        return Icons.business;
    }
  }

  Color _getEventColor(String? eventType) {
    switch (eventType) {
      case 'ObjectEvent':
        return Colors.blue;
      case 'AggregationEvent':
        return Colors.green;
      case 'TransactionEvent':
        return Colors.orange;
      case 'TransformationEvent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      if (timestamp is String) {
        return DateTime.parse(timestamp).toString();
      } else if (timestamp is DateTime) {
        return timestamp.toString();
      }
      return timestamp.toString();
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
