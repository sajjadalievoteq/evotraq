import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/features/gs1/bloc/sscc/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/models/sscc_model.dart';

class SSCCAdvancedListScreen extends StatefulWidget {
  const SSCCAdvancedListScreen({Key? key}) : super(key: key);

  @override
  State<SSCCAdvancedListScreen> createState() => _SSCCAdvancedListScreenState();
}

class _SSCCAdvancedListScreenState extends State<SSCCAdvancedListScreen> {
  final _scrollController = ScrollController();
  
  // Filter controllers
  final _ssccCodeController = TextEditingController();
  final _sourceLocationNameController = TextEditingController();
  final _destinationLocationNameController = TextEditingController();
  final _gs1CompanyPrefixController = TextEditingController();
  
  // Filter state
  ContainerType? _selectedContainerType;
  ContainerStatus? _selectedContainerStatus;
  String _sortBy = 'ssccCode';
  String _sortDirection = 'ASC';
  bool _showAdvancedFilters = false;
  
  // Current page and data state
  int _currentPage = 0;
  final int _pageSize = 20;
  List<SSCC> _ssccs = [];
  bool _hasMoreData = true;
  int _totalElements = 0;
  
  // Debounce timer for search
  Timer? _debounceTimer;
  
  // Container Type options
  final List<ContainerType?> _containerTypeOptions = [null, ...ContainerType.values];
  
  // Container Status options
  final List<ContainerStatus?> _containerStatusOptions = [null, ...ContainerStatus.values];
  
  // Sort options
  final List<Map<String, String>> _sortOptions = [
    {'value': 'ssccCode', 'label': 'SSCC Code'},
    {'value': 'containerType', 'label': 'Container Type'},
    {'value': 'containerStatus', 'label': 'Container Status'},
    {'value': 'createdAt', 'label': 'Created Date'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Add listeners for real-time filtering
    _ssccCodeController.addListener(_onFilterChanged);
    _sourceLocationNameController.addListener(_onFilterChanged);
    _destinationLocationNameController.addListener(_onFilterChanged);
    _gs1CompanyPrefixController.addListener(_onFilterChanged);
    
    // Initial load
    _performSearch();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _ssccCodeController.dispose();
    _sourceLocationNameController.dispose();
    _destinationLocationNameController.dispose();
    _gs1CompanyPrefixController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && _hasMoreData) {
      final currentState = context.read<SSCCCubit>().state;
      if (currentState.status != SSCCStatus.loading) {
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
      _performSearch(reset: true);
    });
  }

  void _performSearch({bool loadMore = false, bool reset = false}) {
    if (reset || !loadMore) {
      _currentPage = 0;
      _ssccs.clear();
      _hasMoreData = true;
    }

    context.read<SSCCCubit>().searchSSCCsAdvanced(
      ssccCode: _ssccCodeController.text.isNotEmpty ? _ssccCodeController.text : null,
      containerType: _selectedContainerType?.name,
      containerStatus: _selectedContainerStatus?.name,
      sourceLocationName: _sourceLocationNameController.text.isNotEmpty ? _sourceLocationNameController.text : null,
      destinationLocationName: _destinationLocationNameController.text.isNotEmpty ? _destinationLocationNameController.text : null,
      gs1CompanyPrefix: _gs1CompanyPrefixController.text.isNotEmpty ? _gs1CompanyPrefixController.text : null,
      page: _currentPage,
      size: _pageSize,
      sortBy: _sortBy,
      direction: _sortDirection,
    );
  }

  void _clearAllFilters() {
    setState(() {
      _ssccCodeController.clear();
      _sourceLocationNameController.clear();
      _destinationLocationNameController.clear();
      _gs1CompanyPrefixController.clear();
      _selectedContainerType = null;
      _selectedContainerStatus = null;
    });
    _performSearch(reset: true);
  }

  void _clearAdvancedFilters() {
    setState(() {
      _sourceLocationNameController.clear();
      _destinationLocationNameController.clear();
      _gs1CompanyPrefixController.clear();
    });
    _performSearch(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSCC Management'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sort') {
                _showSortDialog();
              } else if (value == 'create') {
                context.push('/gs1/ssccs/new');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort),
                    SizedBox(width: 8),
                    Text('Sort Options'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'create',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Create SSCC'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildResultsHeader(),
          Expanded(
            child: BlocConsumer<SSCCCubit, SSCCState>(
              listener: (context, state) {
                if (state.status == SSCCStatus.success) {
                  if (_currentPage == 0) {
                    _ssccs = state.ssccs;
                  } else {
                    // This logic might need adjustment if state.ssccs 
                    // already contains previous items depending on Cubit implementation.
                    // In our SSCCCubit, searchSSCCsAdvanced handles appending.
                    _ssccs = state.ssccs;
                  }
                  _totalElements = state.totalElements;
                  _hasMoreData = state.page < state.totalPages - 1;
                  if (_hasMoreData && state.status == SSCCStatus.success) {
                    _currentPage = state.page + 1;
                  }
                }
              },
              builder: (context, state) {
                if (state.status == SSCCStatus.loading && _ssccs.isEmpty) {
                  return const LoadingIndicator();
                }

                if (state.status == SSCCStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.error}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _performSearch(reset: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (_ssccs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No SSCCs found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _ssccs.length + (state.status == SSCCStatus.loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _ssccs.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: LoadingIndicator()),
                      );
                    }

                    final sscc = _ssccs[index];
                    return _buildSSCCCard(sscc);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/gs1/ssccs/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ssccCodeController,
                    decoration: const InputDecoration(
                      labelText: 'SSCC Code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<ContainerType?>(
                    value: _selectedContainerType,
                    decoration: const InputDecoration(
                      labelText: 'Container Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _containerTypeOptions.map((type) {
                      return DropdownMenuItem<ContainerType?>(
                        value: type,
                        child: Text(type?.name ?? 'All'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedContainerType = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<ContainerStatus?>(
                    value: _selectedContainerStatus,
                    decoration: const InputDecoration(
                      labelText: 'Container Status',
                      border: OutlineInputBorder(),
                    ),
                    items: _containerStatusOptions.map((status) {
                      return DropdownMenuItem<ContainerStatus?>(
                        value: status,
                        child: Text(status?.name ?? 'All'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedContainerStatus = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Advanced filters toggle with clear button
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAdvancedFilters = !_showAdvancedFilters;
                    });
                  },
                  icon: Icon(
                    _showAdvancedFilters ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
                  label: const Text('Advanced Filters'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All Filters'),
                ),
              ],
            ),

            if (_showAdvancedFilters) ...[
              const Divider(),
              const SizedBox(height: 8),
              
              // Location filters
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _sourceLocationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Source Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _destinationLocationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Destination Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Company prefix filter
              TextField(
                controller: _gs1CompanyPrefixController,
                decoration: const InputDecoration(
                  labelText: 'GS1 Company Prefix',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),

              const SizedBox(height: 16),
              
              // Clear advanced filters button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearAdvancedFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Advanced Filters'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Results: $_totalElements SSCCs',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          if (_hasActiveFilters)
            Chip(
              label: Text('${_getActiveFilterCount()} filters active'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters {
    return _ssccCodeController.text.isNotEmpty ||
           _selectedContainerType != null ||
           _selectedContainerStatus != null ||
           _sourceLocationNameController.text.isNotEmpty ||
           _destinationLocationNameController.text.isNotEmpty ||
           _gs1CompanyPrefixController.text.isNotEmpty;
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_ssccCodeController.text.isNotEmpty) count++;
    if (_selectedContainerType != null) count++;
    if (_selectedContainerStatus != null) count++;
    if (_sourceLocationNameController.text.isNotEmpty) count++;
    if (_destinationLocationNameController.text.isNotEmpty) count++;
    if (_gs1CompanyPrefixController.text.isNotEmpty) count++;
    return count;
  }

  Widget _buildSSCCCard(SSCC sscc) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () => context.push('/gs1/ssccs/${sscc.ssccCode}', extra: sscc.ssccCode),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sscc.ssccCode,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildStatusChip(sscc.containerStatus),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getContainerTypeIcon(sscc.containerType),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sscc.containerType.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(width: 16),
                  if (sscc.gs1CompanyPrefix?.isNotEmpty == true) ...[
                    Icon(
                      Icons.business,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sscc.gs1CompanyPrefix!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ],
              ),
              if (sscc.sourceLocation?.locationName?.isNotEmpty == true ||
                  sscc.destinationLocation?.locationName?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (sscc.sourceLocation?.locationName?.isNotEmpty == true) ...[
                      const Icon(Icons.location_on, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'From: ${sscc.sourceLocation!.locationName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (sscc.destinationLocation?.locationName?.isNotEmpty == true) ...[
                      const Icon(Icons.location_on, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        'To: ${sscc.destinationLocation!.locationName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
              // Show issuing GLN (more important for supply chain traceability than packing date)
              if (sscc.issuingGLN != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.factory, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    Text(
                      'Issuing GLN: ${sscc.issuingGLN!.glnCode}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              // Show shipping date if available (keep this as it's still valuable)
              if (sscc.shippingDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_shipping, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Shipped: ${DateFormat('yyyy-MM-dd').format(sscc.shippingDate!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ContainerStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case ContainerStatus.CREATED:
        backgroundColor = Colors.grey[300]!;
        textColor = Colors.black;
        break;
      case ContainerStatus.PACKED:
        backgroundColor = Colors.blue[300]!;
        textColor = Colors.white;
        break;
      case ContainerStatus.SHIPPED:
        backgroundColor = Colors.orange[300]!;
        textColor = Colors.white;
        break;
      case ContainerStatus.IN_TRANSIT:
        backgroundColor = Colors.purple[300]!;
        textColor = Colors.white;
        break;
      case ContainerStatus.RECEIVED:
        backgroundColor = Colors.green[300]!;
        textColor = Colors.white;
        break;
      case ContainerStatus.UNPACKED:
        backgroundColor = Colors.indigo[300]!;
        textColor = Colors.white;
        break;
      case ContainerStatus.DAMAGED:
        backgroundColor = Colors.red[300]!;
        textColor = Colors.white;
        break;
      case ContainerStatus.DISPOSED:
        backgroundColor = Colors.grey[600]!;
        textColor = Colors.white;
        break;
    }

    return Chip(
      label: Text(
        status.name,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  IconData _getContainerTypeIcon(ContainerType type) {
    switch (type) {
      case ContainerType.PALLET:
        return Icons.inventory_2;
      case ContainerType.CASE:
        return Icons.inventory;
      case ContainerType.TOTE:
        return Icons.shopping_basket;
      case ContainerType.CONTAINER:
        return Icons.storage;
      case ContainerType.DRUM:
        return Icons.circle_outlined;
      case ContainerType.CARTON:
        return Icons.inventory_outlined;
      case ContainerType.OTHER:
        return Icons.category;
    }
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: const InputDecoration(
                  labelText: 'Sort By',
                  border: OutlineInputBorder(),
                ),
                items: _sortOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value']!,
                    child: Text(option['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortBy = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sortDirection,
                decoration: const InputDecoration(
                  labelText: 'Sort Direction',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ASC', child: Text('Ascending')),
                  DropdownMenuItem(value: 'DESC', child: Text('Descending')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortDirection = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performSearch(reset: true);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
