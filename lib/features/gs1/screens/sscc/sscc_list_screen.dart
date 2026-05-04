// filepath: c:\Code\traqTrace\frontend\traqtrace_app\lib\features\gs1\screens\sscc\sscc_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/gs1/bloc/sscc/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/models/sscc_model.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

class SSCCListScreen extends StatefulWidget {
  const SSCCListScreen({Key? key}) : super(key: key);

  @override
  State<SSCCListScreen> createState() => _SSCCListScreenState();
}

class _SSCCListScreenState extends State<SSCCListScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 0;
  final int _pageSize = 20;
  
  ContainerType? _selectedContainerType;
  ContainerStatus? _selectedContainerStatus;

  @override
  void initState() {
    super.initState();
    // Load SSCCs when the screen initializes
    _loadSSCCs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSSCCs() {
    context.read<SSCCCubit>().fetchSSCCs(
      page: _currentPage,
      size: _pageSize,
    );
  }

  void _searchSSCCs() {
    context.read<SSCCCubit>().searchSSCCsAdvanced(
      ssccCode: _searchController.text.isNotEmpty ? _searchController.text : null,
      containerType: _selectedContainerType?.name,
      containerStatus: _selectedContainerStatus?.name,
      page: 0,
      size: _pageSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serial Shipping Container Codes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSSCCs,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: BlocConsumer<SSCCCubit, SSCCState>(
              listener: (context, state) {
                if (state.status == SSCCStatus.error && state.error != null) {
                  context.showError(state.error!);
                }
              },
              builder: (context, state) {
                if (state.status == SSCCStatus.loading && state.ssccs.isEmpty) {
                  return const Center(child: LoadingIndicator());
                } else if (state.ssccs.isNotEmpty || state.status == SSCCStatus.success) {
                  return _buildSSCCList(state.ssccs);
                } else if (state.status == SSCCStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.error ?? 'An error occurred'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadSSCCs,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('No SSCCs found'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/gs1/ssccs/new').then((_) => _loadSSCCs());
        },
        child: const Icon(Icons.add),
        tooltip: 'Create SSCC',
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _loadSSCCs();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onSubmitted: (_) => _searchSSCCs(),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: _buildContainerTypeDropdown(),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildContainerStatusDropdown(),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: _searchSSCCs,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: const Text('Filter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContainerTypeDropdown() {
    return DropdownButtonFormField<ContainerType>(
      decoration: InputDecoration(
        labelText: 'Container Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      value: _selectedContainerType,
      items: ContainerType.values.map((type) {
        return DropdownMenuItem<ContainerType>(
          value: type,
          child: Text(type.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedContainerType = value;
        });
      },
    );
  }

  Widget _buildContainerStatusDropdown() {
    return DropdownButtonFormField<ContainerStatus>(
      decoration: InputDecoration(
        labelText: 'Container Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      value: _selectedContainerStatus,
      items: ContainerStatus.values.map((status) {
        return DropdownMenuItem<ContainerStatus>(
          value: status,
          child: Text(status.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedContainerStatus = value;
        });
      },
    );
  }

  Widget _buildSSCCList(List<SSCC> ssccs) {
    if (ssccs.isEmpty) {
      return const Center(
        child: Text('No SSCCs found'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadSSCCs(),
      child: ListView.builder(
        itemCount: ssccs.length,
        itemBuilder: (context, index) {
          final sscc = ssccs[index];
          return _buildSSCCListItem(sscc);
        },
      ),
    );
  }

  Widget _buildSSCCListItem(SSCC sscc) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusColor = _getStatusColor(sscc.containerStatus);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text(
          sscc.ssccCode,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text('Type: ${sscc.containerType.name}'),
            if (sscc.packingDate != null)
              Text('Packed: ${dateFormat.format(sscc.packingDate!)}'),
            Row(
              children: [
                const Text('Status: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    sscc.containerStatus.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),        onTap: () {
          print('Navigating to SSCC details: ID=${sscc.id}, Code=${sscc.ssccCode}');
          
          // Show a loading message
          context.showInfo('Loading SSCC details...', duration: const Duration(seconds: 1));
          
          // Use SSCC code as fallback when ID is null
          final routeParam = sscc.id?.isNotEmpty == true ? sscc.id! : sscc.ssccCode;
          
          // Use GoRouter to navigate to SSCC detail screen, passing ssccCode as extra data
          context.push('/gs1/ssccs/$routeParam', extra: sscc.ssccCode).then((_) => _loadSSCCs());
        },
      ),
    );
  }

  Color _getStatusColor(ContainerStatus status) {
    switch (status) {
      case ContainerStatus.CREATED:
        return Colors.blue;
      case ContainerStatus.PACKED:
        return Colors.green;
      case ContainerStatus.SHIPPED:
        return Colors.orange;
      case ContainerStatus.IN_TRANSIT:
        return Colors.deepPurple;
      case ContainerStatus.RECEIVED:
        return Colors.teal;
      case ContainerStatus.UNPACKED:
        return Colors.amber;
      case ContainerStatus.DAMAGED:
        return Colors.red;
      case ContainerStatus.DISPOSED:
        return Colors.grey;
    }
  }
}