import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/features/gs1/bloc/sgtin/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/models/sgtin_model.dart';

class SGTINAdvancedListScreen extends StatefulWidget {
  const SGTINAdvancedListScreen({Key? key}) : super(key: key);

  @override
  State<SGTINAdvancedListScreen> createState() => _SGTINAdvancedListScreenState();
}

class _SGTINAdvancedListScreenState extends State<SGTINAdvancedListScreen> {
  final _scrollController = ScrollController();
  
  // Filter controllers
  final _gtinCodeController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _batchLotController = TextEditingController();
  final _locationNameController = TextEditingController();
  
  // Filter state
  ItemStatus? _selectedStatus;
  String _sortBy = 'createdAt';
  String _sortDirection = 'DESC';
  bool _showAdvancedFilters = false;
  
  // Debounce timer for search
  Timer? _debounceTimer;
  
  // Status options
  final List<ItemStatus?> _statusOptions = [null, ...ItemStatus.values];
  
  // Sort options
  final List<Map<String, String>> _sortOptions = [
    {'value': 'createdAt', 'label': 'Created Date'},
    {'value': 'gtinCode', 'label': 'GTIN Code'},
    {'value': 'serialNumber', 'label': 'Serial Number'},
    {'value': 'batchLotNumber', 'label': 'Batch/Lot'},
    {'value': 'status', 'label': 'Status'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Add listeners for real-time filtering
    _gtinCodeController.addListener(_onFilterChanged);
    _serialNumberController.addListener(_onFilterChanged);
    _batchLotController.addListener(_onFilterChanged);
    _locationNameController.addListener(_onFilterChanged);
    
    // Initial load
    _performSearch();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _gtinCodeController.dispose();
    _serialNumberController.dispose();
    _batchLotController.dispose();
    _locationNameController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<SGTINCubit>().state;
      if (currentState.status != SGTINStatus.loading && currentState.hasMoreData) {
        _performSearch(loadMore: true);
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onFilterChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _onDropdownChanged() {
    // For dropdown changes, search immediately
    _performSearch();
  }

  void _performSearch({bool loadMore = false}) {
    context.read<SGTINCubit>().fetchSGTINList(
        gtinCode: _gtinCodeController.text.trim().isEmpty ? null : _gtinCodeController.text.trim(),
        serialNumber: _serialNumberController.text.trim().isEmpty ? null : _serialNumberController.text.trim(),
        batchLotNumber: _batchLotController.text.trim().isEmpty ? null : _batchLotController.text.trim(),
        status: _selectedStatus?.name,
        locationName: _locationNameController.text.trim().isEmpty ? null : _locationNameController.text.trim(),
        page: loadMore ? (context.read<SGTINCubit>().state.currentPage + 1) : 0,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
        isLoadMore: loadMore,
      );
  }

  void _clearFilters() {
    setState(() {
      _gtinCodeController.clear();
      _serialNumberController.clear();
      _batchLotController.clear();
      _locationNameController.clear();
      _selectedStatus = null;
      _sortBy = 'createdAt';
      _sortDirection = 'DESC';
    });
    _performSearch();
  }

  void _clearAdvancedFilters() {
    setState(() {
      _batchLotController.clear();
      _locationNameController.clear();
    });
    _performSearch();
  }

  void _navigateToCreateSGTIN() {
    context.push('/gs1/sgtins/new');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SGTIN Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _performSearch,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateSGTIN,
        child: const Icon(Icons.add),
        tooltip: 'Create New SGTIN',
      ),
      body: Column(
        children: [
          // Filters Section
          _buildFiltersSection(),
          // Results Section
          Expanded(
            child: BlocBuilder<SGTINCubit, SGTINState>(
              builder: (context, state) {
                if (state.status == SGTINStatus.loading && (state.sgtins?.isEmpty ?? true)) {
                  return const Center(child: LoadingIndicator());
                }
                
                if (state.status == SGTINStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('Error: ${state.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _performSearch,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                final sgtins = state.sgtins ?? [];
                
                if (sgtins.isEmpty && state.status != SGTINStatus.loading) {
                  return _buildEmptyState();
                }
                
                return _buildSGTINList(sgtins, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic filters row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _gtinCodeController,
                    decoration: const InputDecoration(
                      labelText: 'GTIN Code',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _serialNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Serial Number',
                      prefixIcon: Icon(Icons.tag),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<ItemStatus?>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _statusOptions.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status?.name ?? 'All Statuses'),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      _onDropdownChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear Filters',
                ),
              ],
            ),
            
            // Advanced filters toggle
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _showAdvancedFilters = !_showAdvancedFilters;
                });
              },
              child: Row(
                children: [
                  Icon(
                    _showAdvancedFilters 
                      ? Icons.keyboard_arrow_down 
                      : Icons.keyboard_arrow_right,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Advanced Filters',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Advanced filters (collapsible)
            if (_showAdvancedFilters) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              // Second row - Batch/Lot and Location
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _batchLotController,
                      decoration: const InputDecoration(
                        labelText: 'Batch/Lot Number',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _locationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Location Name',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Clear Advanced Filters button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _clearAdvancedFilters,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear Advanced Filters'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Sort controls and counts
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _sortOptions.map((option) => DropdownMenuItem(
                      value: option['value'],
                      child: Text(option['label']!),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                      _onDropdownChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortDirection,
                    decoration: const InputDecoration(
                      labelText: 'Order',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ASC', child: Text('Ascending')),
                      DropdownMenuItem(value: 'DESC', child: Text('Descending')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortDirection = value!;
                      });
                      _onDropdownChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                BlocBuilder<SGTINCubit, SGTINState>(
                  builder: (context, state) {
                    return Text(
                      'Showing ${state.sgtins?.length ?? 0} of ${state.totalElements} SGTINs',
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No SGTINs Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or create a new SGTIN',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _navigateToCreateSGTIN,
            icon: const Icon(Icons.add),
            label: const Text('Create New SGTIN'),
          ),
        ],
      ),
    );
  }

  Widget _buildSGTINList(List<SGTIN> sgtins, SGTINState state) {
    return RefreshIndicator(
      onRefresh: () async {
        _performSearch();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: sgtins.length + (state.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == sgtins.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: LoadingIndicator()),
            );
          }

          final sgtin = sgtins[index];
          return _buildSGTINCard(sgtin);
        },
      ),
    );
  }

  Widget _buildSGTINCard(SGTIN sgtin) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(sgtin.status),
          child: const Icon(Icons.qr_code_2, color: Colors.white),
        ),
        title: Text(
          '${sgtin.gtinCode} / ${sgtin.serialNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sgtin.batchLotNumber != null)
              Text('Batch: ${sgtin.batchLotNumber}'),
            Row(
              children: [
                Chip(
                  label: Text(sgtin.status.name),
                  backgroundColor: _getStatusColor(sgtin.status),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 8),
                if (sgtin.expiryDate != null)
                  Text(
                    'Expires: ${DateFormat('dd/MM/yyyy').format(sgtin.expiryDate!)}',
                    style: TextStyle(
                      color: sgtin.expiryDate!.isBefore(DateTime.now()) 
                        ? Colors.red 
                        : Colors.grey[600],
                    ),
                  ),
              ],
            ),
            if (sgtin.currentLocation?.locationName != null)
              Text('Location: ${sgtin.currentLocation!.locationName}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            switch (action) {
              case 'view':
                context.push('/gs1/sgtins/${sgtin.id}');
                break;
              case 'edit':
                context.push('/gs1/sgtins/${sgtin.id}/edit');
                break;
              case 'delete':
                _showDeleteConfirmation(context, sgtin);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => context.push('/gs1/sgtins/${sgtin.id}'),
      ),
    );
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.COMMISSIONED:
        return Colors.blue;
      case ItemStatus.PACKED:
        return Colors.orange;
      case ItemStatus.SHIPPED:
        return Colors.purple;
      case ItemStatus.IN_TRANSIT:
        return Colors.indigo;
      case ItemStatus.RECEIVED:
        return Colors.green;
      case ItemStatus.DISPENSED:
        return Colors.teal;
      case ItemStatus.DAMAGED:
        return Colors.red;
      case ItemStatus.RECALLED:
        return Colors.red[800]!;
      case ItemStatus.STOLEN:
        return Colors.red[900]!;
      case ItemStatus.DESTROYED:
        return Colors.black;
      case ItemStatus.SAMPLE:
        return Colors.amber;
      case ItemStatus.DECOMMISSIONED:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(BuildContext context, SGTIN sgtin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete SGTIN'),
          content: Text('Are you sure you want to delete SGTIN ${sgtin.serialNumber}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (sgtin.id != null) {
                  context.read<SGTINCubit>().deleteSGTIN(sgtin.id!);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
