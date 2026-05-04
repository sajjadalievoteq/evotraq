import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/gs1/bloc/sgtin/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/models/sgtin_model.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

class SGTINListScreen extends StatefulWidget {
  const SGTINListScreen({Key? key}) : super(key: key);

  @override
  State<SGTINListScreen> createState() => _SGTINListScreenState();
}

class _SGTINListScreenState extends State<SGTINListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedBatchLot;
  
  final _statusOptions = ['All', ...ItemStatus.values.map((e) => e.name)];
  final int _pageSize = 20;

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initial load of SGTINs
    context.read<SGTINCubit>().fetchSGTINList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && context.read<SGTINCubit>().state.hasMoreData) {
      final currentPage = context.read<SGTINCubit>().state.currentPage;
      
      // Apply search if text is entered
      if (_searchController.text.isNotEmpty) {
        // Use appropriate search event based on what you're searching for
        context.read<SGTINCubit>().searchSGTINs(
          batchLotNumber: _selectedBatchLot,
          status: _selectedStatus != null && _selectedStatus != 'All' 
              ? ItemStatus.values.firstWhere((e) => e.name == _selectedStatus).name
              : null,
          page: currentPage + 1,
          size: _pageSize,
        );
      } else {
        // Just load the next page
        context.read<SGTINCubit>().fetchSGTINList(
          page: currentPage + 1,
          size: _pageSize,
          isLoadMore: true,
        );
      }
    }
  }

  void _onSearch() {
    // Reset to first page when searching
    if (_searchController.text.isNotEmpty || _selectedStatus != null || _selectedBatchLot != null) {
      context.read<SGTINCubit>().searchSGTINs(
        batchLotNumber: _selectedBatchLot,
        status: _selectedStatus != null && _selectedStatus != 'All' 
            ? ItemStatus.values.firstWhere((e) => e.name == _selectedStatus).name
            : null,
        page: 0,
        size: _pageSize,
      );
    } else {
      context.read<SGTINCubit>().fetchSGTINList(
        page: 0,
        size: _pageSize,
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedBatchLot = null;
    });
    
    // Reset and load all SGTINs
    context.read<SGTINCubit>().fetchSGTINList();
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<SGTINCubit, SGTINState>(
      listenWhen: (previous, current) => 
        current.status != previous.status ||
        current.error != previous.error,
      listener: (context, state) {
        // Show error if present
        if (state.status == SGTINStatus.error && state.error != null) {
          context.showError('Error: ${state.error}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Serialized GTINs'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SGTINCubit>().fetchSGTINList();
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _buildSGTINList(),
            ),
          ],
        ),      floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to create SGTIN screen using GoRouter
            context.go('/gs1/sgtins/new');
          },
          tooltip: 'Add New SGTIN',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search SGTIN',
                    hintText: 'Enter serial number or GTIN',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // Show filter options in bottom sheet
                  _showFilterSheet();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_selectedStatus != null || _selectedBatchLot != null)
            Row(
              children: [
                if (_selectedStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Chip(
                      label: Text('Status: $_selectedStatus'),
                      onDeleted: () {
                        setState(() {
                          _selectedStatus = null;
                        });
                        _onSearch();
                      },
                    ),
                  ),
                if (_selectedBatchLot != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Chip(
                      label: Text('Batch/Lot: $_selectedBatchLot'),
                      onDeleted: () {
                        setState(() {
                          _selectedBatchLot = null;
                        });
                        _onSearch();
                      },
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSGTINList() {
    return BlocBuilder<SGTINCubit, SGTINState>(
      builder: (context, state) {
        if (state.status == SGTINStatus.loading && (state.sgtins == null || state.sgtins!.isEmpty)) {
          return const LoadingIndicator();
        } else if (state.status == SGTINStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.error ?? 'Failed to load SGTINs'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<SGTINCubit>().fetchSGTINList();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state.sgtins == null || state.sgtins!.isEmpty) {
          return const Center(
            child: Text('No SGTINs found'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            context.read<SGTINCubit>().fetchSGTINList();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.sgtins!.length + (state.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.sgtins!.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );              }              final sgtin = state.sgtins![index];
              return _buildSGTINListItem(sgtin);
            },
          ),
        );
      },
    );
  }

  Widget _buildSGTINListItem(SGTIN sgtin) {
    // Debug print to check what's in the SGTIN
    print('SGTIN data: ${sgtin.gtinCode}, ${sgtin.serialNumber}, ${sgtin.status}');
    
    final expiryDateString = sgtin.expiryDate != null
        ? DateFormat('yyyy-MM-dd').format(sgtin.expiryDate!)
        : 'N/A';
    
    // Get color based on status
    Color statusColor;
    switch (sgtin.status) {
      case ItemStatus.COMMISSIONED:
        statusColor = Colors.green;
        break;
      case ItemStatus.DECOMMISSIONED:
        statusColor = Colors.red;
        break;
      case ItemStatus.PACKED:
      case ItemStatus.SHIPPED:
      case ItemStatus.IN_TRANSIT:
        statusColor = Colors.blue;
        break;
      case ItemStatus.DISPENSED:
        statusColor = Colors.orange;
        break;
      case ItemStatus.RECALLED:
      case ItemStatus.STOLEN:
      case ItemStatus.DAMAGED:
      case ItemStatus.DESTROYED:
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text('${sgtin.gtinCode} - ${sgtin.serialNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Batch: ${sgtin.batchLotNumber ?? 'N/A'}'),
            Text('Expires: $expiryDateString'),
            const SizedBox(height: 4),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            sgtin.status.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),        onTap: () {
          if (sgtin.id != null && sgtin.id!.isNotEmpty) {
            // Navigate to detail screen using GoRouter with the UUID string
            context.go('/gs1/sgtins/${sgtin.id.toString()}');
          } else {
            // Handle case when ID is null or empty
            context.showWarning('Cannot view SGTIN: Invalid ID');
            // Log this occurrence for debugging
            print('Warning: Attempted to navigate to SGTIN with null or empty ID: $sgtin');
          }
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Filter SGTINs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedStatus,
                    items: _statusOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Batch/Lot Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedBatchLot = value.isNotEmpty ? value : null;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _onSearch();
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}