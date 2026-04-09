import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/features/gs1/bloc/gln/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';

/// Screen to display and manage GLNs (Global Location Numbers)
class GLNListScreen extends StatefulWidget {
  const GLNListScreen({Key? key}) : super(key: key);

  @override
  State<GLNListScreen> createState() => _GLNListScreenState();
}

class _GLNListScreenState extends State<GLNListScreen> {
  final _searchController = TextEditingController();
  final _glnCodeController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _scrollController = ScrollController();
  
  Timer? _debounceTimer;
  
  String? _selectedStatus;
  String? _selectedLocationType;
  String _sortBy = 'locationName';
  String _sortOrder = 'asc';
  int _pageSize = 25;
  bool _showAdvancedFilters = false;
  
  final _statusOptions = ['All', 'Active', 'Inactive'];
  final _locationTypeOptions = [
    'All',
    'Manufacturing Site',
    'Warehouse',
    'Distribution Center',
    'Pharmacy',
    'Hospital',
    'Wholesaler',
    'Clinic',
    'Regulatory Body',
    'Other'
  ];
  final _sortOptions = {
    'locationName': 'Location Name',
    'glnCode': 'GLN Code',
    'addressLine1': 'Address',
    'city': 'City',
    'licenseNumber': 'License Number'
  };
  final _pageSizeOptions = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initial load of GLNs with advanced filtering
    // Use _search() to ensure consistent parameter handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _glnCodeController.dispose();
    _locationNameController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _contactEmailController.dispose();
    _contactNameController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _debouncedSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _search();
    });
  }

  String? _getAdvancedFilterValue(String filterType) {
    switch (filterType) {
      case 'glnCode':
        return _glnCodeController.text.isEmpty ? null : _glnCodeController.text;
      case 'locationName':
        return _locationNameController.text.isEmpty ? null : _locationNameController.text;
      case 'address':
        return _addressController.text.isEmpty ? null : _addressController.text;
      case 'licenseNumber':
        return _licenseNumberController.text.isEmpty ? null : _licenseNumberController.text;
      case 'contactEmail':
        return _contactEmailController.text.isEmpty ? null : _contactEmailController.text;
      case 'contactName':
        return _contactNameController.text.isEmpty ? null : _contactNameController.text;
      default:
        return null;
    }
  }

  void _onScroll() {
    if (_isBottom && context.read<GLNCubit>().state.hasMoreData) {
      final currentPage = context.read<GLNCubit>().state.currentPage ?? 0;
      context.read<GLNCubit>().searchGLNsAdvanced(
          search: _searchController.text.isEmpty ? null : _searchController.text,
          glnCode: _getAdvancedFilterValue('glnCode'),
          locationName: _getAdvancedFilterValue('locationName'),
          address: _getAdvancedFilterValue('address'),
          licenseNumber: _getAdvancedFilterValue('licenseNumber'),
          contactEmail: _getAdvancedFilterValue('contactEmail'),
          contactName: _getAdvancedFilterValue('contactName'),
          active: _selectedStatus == null || _selectedStatus == 'All' ? null : (_selectedStatus?.toLowerCase() == 'active'),
          locationType: _selectedLocationType == null || _selectedLocationType == 'All' ? null : _selectedLocationType?.replaceAll(' ', '_').toLowerCase(),
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
    context.read<GLNCubit>().searchGLNsAdvanced(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      glnCode: _getAdvancedFilterValue('glnCode'),
      locationName: _getAdvancedFilterValue('locationName'),
      address: _getAdvancedFilterValue('address'),
      licenseNumber: _getAdvancedFilterValue('licenseNumber'),
      contactEmail: _getAdvancedFilterValue('contactEmail'),
      contactName: _getAdvancedFilterValue('contactName'),
      active: _selectedStatus == null || _selectedStatus == 'All' ? null : (_selectedStatus?.toLowerCase() == 'active'),
      locationType: _selectedLocationType == null || _selectedLocationType == 'All' ? null : _selectedLocationType?.replaceAll(' ', '_').toLowerCase(),
      page: 0,
      size: _pageSize,
      sortBy: _sortBy,
      direction: _sortOrder.toUpperCase(),
    );
    
    // Debug logging
    print('DEBUG: GLN Search parameters:');
    print('  search: ${_searchController.text.isEmpty ? null : _searchController.text}');
    print('  glnCode: ${_getAdvancedFilterValue('glnCode')}');
    print('  locationName: ${_getAdvancedFilterValue('locationName')}');
    print('  address: ${_getAdvancedFilterValue('address')}');
    print('  _selectedStatus: $_selectedStatus');
    print('  active: ${_selectedStatus == null || _selectedStatus == 'All' ? null : (_selectedStatus?.toLowerCase() == 'active')}');
    print('  locationType: ${_selectedLocationType == null || _selectedLocationType == 'All' ? null : _selectedLocationType?.replaceAll(' ', '_').toLowerCase()}');
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
                  const Text('Location Name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationNameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Main Warehouse, Central Pharmacy',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _debouncedSearch(); // Trigger database search when location name changes
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
                      _search(); // Trigger database search when status filter changes
                    },
                    items: _statusOptions
                        .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Location Type'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedLocationType ?? 'All',
                    onChanged: (value) {
                      setState(() {
                        _selectedLocationType = value;
                      });
                      _search(); // Trigger database search when location type filter changes
                    },
                    items: _locationTypeOptions
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _search();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateGLN() {
    context.push('/gs1/glns/new');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<GLNCubit, GLNState>(
          builder: (context, state) {
            if (state.glns.isNotEmpty) {
              final loadedCount = state.glns.length;
              final hasMore = state.hasMoreData;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GLN Management'),
                  Text(
                    hasMore ? '$loadedCount+ records loaded' : '$loadedCount records total',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              );
            }
            return const Text('GLN Management');
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
            child: _buildGLNList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateGLN,
        tooltip: 'Add New GLN',
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
          hintText: 'Search by GLN code, location name, address, or contact info...',
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
        onChanged: (_) => _debouncedSearch(),
        onSubmitted: (_) => _search(),
      ),
    );
  }

  Widget _buildRecordInfo() {
    return BlocBuilder<GLNCubit, GLNState>(
      builder: (context, state) {
        if (state.glns.isEmpty) return const SizedBox.shrink();
        
        final glns = state.glns;
        final loadedRecords = glns.length;
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
                    ? 'Showing $loadedRecords+ GLNs (scroll for more)'
                    : 'Showing all $loadedRecords GLNs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  DropdownButton<int>(
                    value: _pageSize,
                    items: _pageSizeOptions.map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text('$size/page'),
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

  Widget _buildFilterChips() {
    // Only show filter chips if advanced filters are not visible
    if (_showAdvancedFilters) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        children: [
          if (_locationNameController.text.isNotEmpty)
            Chip(
              label: Text('Location: ${_locationNameController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _locationNameController.clear();
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
          if (_selectedLocationType != null && _selectedLocationType != 'All')
            Chip(
              label: Text('Type: ${_selectedLocationType!}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedLocationType = 'All';
                });
                _search();
              },
            ),
          if (_glnCodeController.text.isNotEmpty)
            Chip(
              label: Text('GLN: ${_glnCodeController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _glnCodeController.clear();
                });
                _search();
              },
            ),
          if (_addressController.text.isNotEmpty)
            Chip(
              label: Text('Address: ${_addressController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _addressController.clear();
                });
                _search();
              },
            ),
          if (_licenseNumberController.text.isNotEmpty)
            Chip(
              label: Text('License: ${_licenseNumberController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _licenseNumberController.clear();
                });
                _search();
              },
            ),
          if (_contactEmailController.text.isNotEmpty)
            Chip(
              label: Text('Email: ${_contactEmailController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _contactEmailController.clear();
                });
                _search();
              },
            ),
          if (_contactNameController.text.isNotEmpty)
            Chip(
              label: Text('Contact: ${_contactNameController.text}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _contactNameController.clear();
                });
                _search();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilterToggle() {
    return Container(
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('Apply Filters'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _glnCodeController.clear();
                      _locationNameController.clear();
                      _addressController.clear();
                      _licenseNumberController.clear();
                      _contactEmailController.clear();
                      _contactNameController.clear();
                      _selectedStatus = 'All';
                      _selectedLocationType = 'All';
                    });
                    _search();
                  },
                  child: const Text('Clear All'),
                ),
              ],
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
                  controller: _locationNameController,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                    hintText: 'e.g., Main Warehouse, Central Pharmacy',
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
                  controller: _glnCodeController,
                  decoration: const InputDecoration(
                    labelText: 'GLN Code',
                    hintText: 'e.g., 1234567890123',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    // Trigger search on change if needed
                    _debouncedSearch();
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
                  value: _selectedLocationType,
                  decoration: const InputDecoration(
                    labelText: 'Location Type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _locationTypeOptions.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocationType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Street, city, state, country',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _debouncedSearch(); // Trigger database search when address changes
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _licenseNumberController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    hintText: 'Regulatory license number',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _debouncedSearch(); // Trigger database search when license number changes
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _contactEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Email',
                    hintText: 'Contact email address',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _debouncedSearch(); // Trigger database search when contact email changes
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _contactNameController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Name',
                    hintText: 'Contact person name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _debouncedSearch(); // Trigger database search when contact name changes
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortingControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
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

  Widget _buildGLNList() {
    return BlocConsumer<GLNCubit, GLNState>(
      listener: (context, state) {
        if (state.status == GLNStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == GLNStatus.initial) {
          return const Center(child: LoadingIndicator());
        }

        if (state.status == GLNStatus.loading && state.glns.isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        if (state.glns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No GLNs found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search criteria or filters',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _navigateToCreateGLN,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New GLN'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: state.glns.length + (state.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.glns.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LoadingIndicator(),
                ),
              );
            }

            final gln = state.glns[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: gln.active ? Colors.green : Colors.red,
                  child: Icon(
                    gln.active ? Icons.location_on : Icons.location_off,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  gln.locationName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'GLN: ${gln.glnCode}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                    if (gln.addressLine1.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(gln.addressLine1, style: const TextStyle(fontSize: 12)),
                    ],
                    if (gln.city.isNotEmpty || gln.country.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${gln.city}${gln.city.isNotEmpty && gln.country.isNotEmpty ? ', ' : ''}${gln.country}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    if (gln.contactEmail?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text('📧 ${gln.contactEmail}', style: const TextStyle(fontSize: 11)),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            gln.active ? 'Active' : 'Inactive',
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: gln.active ? Colors.green[100] : Colors.red[100],
                          labelStyle: TextStyle(
                            color: gln.active ? Colors.green[800] : Colors.red[800],
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        if (gln.locationType.toString().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              gln.locationType.toString().split('.').last.replaceAll('_', ' '),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.blue[100],
                            labelStyle: TextStyle(color: Colors.blue[800]),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    switch (action) {
                      case 'view':
                        context.push('/gs1/glns/${gln.glnCode}');
                        break;
                      case 'edit':
                        context.push('/gs1/glns/${gln.glnCode}/edit');
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, gln);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 20),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () => context.push('/gs1/glns/${gln.glnCode}'),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, GLN gln) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete the GLN for "${gln.locationName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GLNCubit>().deleteGLN(gln.glnCode);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
