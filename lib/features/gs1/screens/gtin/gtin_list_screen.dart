import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/features/gs1/bloc/gtin/gtin_cubit.dart';

class GTINListScreen extends StatefulWidget {
  const GTINListScreen({Key? key}) : super(key: key);

  @override
  State<GTINListScreen> createState() => _GTINListScreenState();
}

class _GTINListScreenState extends State<GTINListScreen> {
  final _searchController = TextEditingController();
  final _productNameController = TextEditingController();
  final _gtinCodeController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _scrollController = ScrollController();
  
  String? _selectedStatus;
  String? _selectedPackagingLevel;
  DateTime? _registrationDateFrom;
  DateTime? _registrationDateTo;
  String _sortBy = 'productName';
  String _sortOrder = 'asc';
  int _pageSize = 25;
  bool _showAdvancedFilters = false;
  
  final _statusOptions = ['All', 'Active', 'Withdrawn', 'Suspended', 'Discontinued'];
  final _packagingLevelOptions = ['All', 'ITEM', 'INNER_PACK', 'PACK', 'CASE', 'PALLET'];
  final _sortOptions = {
    'productName': 'Product Name',
    'gtinCode': 'GTIN Code',
    'manufacturer': 'Manufacturer',
    'registrationDate': 'Registration Date',
    'status': 'Status'
  };
  final _pageSizeOptions = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initial load of GTINs
    context.read<GTINCubit>().fetchGTINList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _productNameController.dispose();
    _gtinCodeController.dispose();
    _manufacturerController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String? _getAdvancedFilterValue(String filterType) {
    switch (filterType) {
      case 'productName':
        return _productNameController.text.isEmpty ? null : _productNameController.text;
      case 'gtinCode':
        return _gtinCodeController.text.isEmpty ? null : _gtinCodeController.text;
      case 'manufacturer':
        return _manufacturerController.text.isEmpty ? null : _manufacturerController.text;
      default:
        return null;
    }
  }

  void _onScroll() {
    if (_isBottom && context.read<GTINCubit>().state.hasMoreData) {
      final currentPage = context.read<GTINCubit>().state.currentPage;
      context.read<GTINCubit>().fetchGTINList(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        productName: _getAdvancedFilterValue('productName'),
        gtinCode: _getAdvancedFilterValue('gtinCode'),
        manufacturer: _getAdvancedFilterValue('manufacturer'),
        status: _selectedStatus == 'All' ? null : _selectedStatus?.toLowerCase(),
        packagingLevel: _selectedPackagingLevel == 'All' ? null : _selectedPackagingLevel,
        registrationDateFrom: _registrationDateFrom?.toIso8601String().split('T')[0],
        registrationDateTo: _registrationDateTo?.toIso8601String().split('T')[0],
        page: currentPage + 1,
        size: _pageSize,
        sortBy: _sortBy,
        direction: _sortOrder.toUpperCase(),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _search() {
    context.read<GTINCubit>().fetchGTINList(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      productName: _getAdvancedFilterValue('productName'),
      gtinCode: _getAdvancedFilterValue('gtinCode'),
      manufacturer: _getAdvancedFilterValue('manufacturer'),
      status: _selectedStatus == 'All' ? null : _selectedStatus?.toLowerCase(),
      packagingLevel: _selectedPackagingLevel == 'All' ? null : _selectedPackagingLevel,
      registrationDateFrom: _registrationDateFrom?.toIso8601String().split('T')[0],
      registrationDateTo: _registrationDateTo?.toIso8601String().split('T')[0],
      page: 0,
      size: _pageSize,
      sortBy: _sortBy,
      direction: _sortOrder.toUpperCase(),
    );
    
    // Debug logging
    print('DEBUG: Search parameters:');
    print('  manufacturer: ${_getAdvancedFilterValue('manufacturer')}');
    print('  productName: ${_getAdvancedFilterValue('productName')}');
    print('  gtinCode: ${_getAdvancedFilterValue('gtinCode')}');
    print('  status: ${_selectedStatus == 'All' ? null : _selectedStatus?.toLowerCase()}');
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Filters'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Manufacturer'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _manufacturerController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Pfizer, Johnson & Johnson',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Status'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedStatus ?? 'All',
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                    items: _statusOptions
                        .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Packaging Level'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedPackagingLevel ?? 'All',
                    onChanged: (value) {
                      setState(() {
                        _selectedPackagingLevel = value;
                      });
                    },
                    items: _packagingLevelOptions
                        .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('For more advanced filters, use the "Show Advanced Filters" option below the search bar.'),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _search();
            },
            child: const Text('Apply'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _manufacturerController.clear();
                _selectedStatus = 'All';
                _selectedPackagingLevel = 'All';
              });
              Navigator.of(context).pop();
              _search();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _navigateToGTINDetails(String gtinCode) {
    context.push('/gs1/gtins/$gtinCode').then((_) => _search()); // Refresh list after returning
  }

  void _navigateToCreateGTIN() {
    context.push('/gs1/gtins/new').then((_) => _search()); // Refresh list after returning
  }

  @override
  Widget build(BuildContext context) {    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<GTINCubit, GTINState>(
          builder: (context, state) {
            if (state.gtins != null) {
              final loadedCount = state.gtins!.length;
              final hasMore = state.hasMoreData;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GTIN Management'),
                  Text(
                    hasMore ? '$loadedCount+ records loaded' : '$loadedCount records total',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              );
            }
            return const Text('GTIN Management');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _search,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Quick Filters',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildRecordInfo(),
          _buildFilterChips(),
          _buildAdvancedFilterToggle(),
          if (_showAdvancedFilters) _buildAdvancedFilters(),
          _buildSortingControls(),
          Expanded(
            child: _buildGTINList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateGTIN,
        tooltip: 'Add New GTIN',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by GTIN code, product name, or manufacturer...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search();
                  },
                ),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  setState(() {
                    _showAdvancedFilters = !_showAdvancedFilters;
                  });
                },
                tooltip: 'Advanced Filters',
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        onSubmitted: (_) => _search(),
      ),
    );
  }

  Widget _buildFilterChips() {
    // Only show filter chips if advanced filters are not visible
    // When advanced filters are shown, the chips can be redundant
    if (_showAdvancedFilters) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        children: [
          if (_manufacturerController.text.isNotEmpty)
            Chip(
              label: Text('Manufacturer: ${_manufacturerController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _manufacturerController.clear();
                });
                _search();
              },
            ),
          if (_selectedStatus != null && _selectedStatus != 'All')
            Chip(
              label: Text('Status: ${_selectedStatus!}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedStatus = 'All';
                });
                _search();
              },
            ),
          if (_selectedPackagingLevel != null && _selectedPackagingLevel != 'All')
            Chip(
              label: Text('Level: ${_selectedPackagingLevel!}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedPackagingLevel = 'All';
                });
                _search();
              },
            ),
          if (_productNameController.text.isNotEmpty)
            Chip(
              label: Text('Product: ${_productNameController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _productNameController.clear();
                });
                _search();
              },
            ),
          if (_gtinCodeController.text.isNotEmpty)
            Chip(
              label: Text('GTIN: ${_gtinCodeController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _gtinCodeController.clear();
                });
                _search();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGTINList() {
    return BlocConsumer<GTINCubit, GTINState>(
      listener: (context, state) {
        if (state.status == GTINStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == GTINStatus.initial) {
          return const Center(child: LoadingIndicator());
        }

        if (state.status == GTINStatus.loading && state.gtins == null) {
          return const Center(child: LoadingIndicator());
        }

        final gtins = state.gtins;
        if (gtins == null || gtins.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No GTINs found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search criteria or filters',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    _clearAllFilters();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear Filters & Search'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _search();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: gtins.length + (state.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= gtins.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final gtin = gtins[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    gtin.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('GTIN: ${gtin.gtinCode}'),
                        ],
                      ),
                      if (gtin.manufacturer != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.business, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('Manufacturer: ${gtin.manufacturer}'),
                          ],
                        ),
                      ],
                      if (gtin.packagingLevel != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('Level: ${gtin.packagingLevel}'),
                          ],
                        ),
                      ],
                      if (gtin.registrationDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('Registered: ${DateFormat('MMM dd, yyyy').format(gtin.registrationDate!)}'),
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatusChip(gtin.status),
                        if (gtin.packSize != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Pack: ${gtin.packSize}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  onTap: () => _navigateToGTINDetails(gtin.gtinCode),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String? status) {
    Color chipColor;
    switch (status?.toLowerCase()) {
      case 'active':
        chipColor = Colors.green;
        break;
      case 'withdrawn':
        chipColor = Colors.red;
        break;
      case 'suspended':
        chipColor = Colors.orange;
        break;
      case 'discontinued':
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Chip(
      label: Text(
        status ?? 'Unknown',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }

  Widget _buildRecordInfo() {
    return BlocBuilder<GTINCubit, GTINState>(
      builder: (context, state) {
        if (state.gtins == null) return const SizedBox.shrink();
        
        final gtins = state.gtins!;
        final loadedRecords = gtins.length;
        final hasMoreData = state.hasMoreData;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasMoreData 
                    ? 'Showing $loadedRecords+ GTINs (scroll for more)'
                    : 'Showing all $loadedRecords GTINs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  if (hasMoreData)
                    Text(
                      'Loaded: ${(loadedRecords / _pageSize).ceil()} batches',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _pageSize,
                    items: _pageSizeOptions.map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text('$size/batch'),
                      );
                    }).toList(),
                    onChanged: (newSize) {
                      if (newSize != null) {
                        setState(() {
                          _pageSize = newSize;
                        });
                        _search(); // This will reset to page 0
                      }
                    },
                    underline: const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedFilterToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showAdvancedFilters = !_showAdvancedFilters;
              });
            },
            icon: Icon(_showAdvancedFilters ? Icons.expand_less : Icons.expand_more),
            label: Text(_showAdvancedFilters ? 'Hide Advanced Filters' : 'Show Advanced Filters'),
          ),
          const Spacer(),
          if (_showAdvancedFilters)
            TextButton(
              onPressed: _clearAllFilters,
              child: const Text('Clear All Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced Filters (Database Filters)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Note: These filters are applied at database level for precise results',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'e.g., Aspirin, Paracetamol',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    // Trigger search on change if needed
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _gtinCodeController,
                  decoration: const InputDecoration(
                    labelText: 'GTIN Code',
                    hintText: 'e.g., 1234567890123',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    // Trigger search on change if needed
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPackagingLevel,
                  decoration: const InputDecoration(
                    labelText: 'Packaging Level',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _packagingLevelOptions.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPackagingLevel = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _manufacturerController,
                  decoration: const InputDecoration(
                    labelText: 'Manufacturer',
                    hintText: 'e.g., Pfizer, Johnson & Johnson',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    // Optional: Auto-search after a delay (debounced search)
                    // You can uncomment the line below if you want auto-search
                    // Future.delayed(const Duration(milliseconds: 500), () => _search());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Reg. Date From',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context, true),
                          ),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _registrationDateFrom != null 
                              ? DateFormat('yyyy-MM-dd').format(_registrationDateFrom!)
                              : '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Reg. Date To',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context, false),
                          ),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _registrationDateTo != null 
                              ? DateFormat('yyyy-MM-dd').format(_registrationDateTo!)
                              : '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Database-level filtering is now active! These filters are applied directly at the database for optimal performance with large datasets.',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortingControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Text('Sort by: '),
          DropdownButton<String>(
            value: _sortBy,
            items: _sortOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sortBy = value;
                });
                _search();
              }
            },
            underline: const SizedBox.shrink(),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(_sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
              });
              _search();
            },
            tooltip: _sortOrder == 'asc' ? 'Ascending' : 'Descending',
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _registrationDateFrom = picked;
        } else {
          _registrationDateTo = picked;
        }
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = 'All';
      _selectedPackagingLevel = 'All';
      _registrationDateFrom = null;
      _registrationDateTo = null;
      _searchController.clear();
      _productNameController.clear();
      _gtinCodeController.clear();
      _manufacturerController.clear();
    });
    _search();
  }
}