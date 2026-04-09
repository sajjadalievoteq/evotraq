import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/operations/packing_models.dart';
import 'package:traqtrace_app/features/epcis/services/operations/packing_operation_service.dart';
import 'package:intl/intl.dart';

/// Screen to list all packing operations with search and filter capabilities
class PackingOperationListScreen extends StatefulWidget {
  const PackingOperationListScreen({Key? key}) : super(key: key);

  @override
  State<PackingOperationListScreen> createState() => _PackingOperationListScreenState();
}

class _PackingOperationListScreenState extends State<PackingOperationListScreen> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  List<PackingResponse> _operations = [];
  List<PackingResponse> _filteredOperations = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterOperations);
    _loadOperations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload operations when navigating back to this screen
    _loadOperations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOperations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final packingService = context.read<PackingOperationService>();
      final operations = await packingService.getAllPackingOperations();
      setState(() {
        _operations = operations;
        _filteredOperations = operations;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load packing operations: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterOperations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOperations = _operations.where((operation) {
        return (operation.packingReference?.toLowerCase().contains(query) ?? false) ||
            (operation.parentContainerId?.toLowerCase().contains(query) ?? false) ||
            (operation.packingLocationGLN?.toLowerCase().contains(query) ?? false) ||
            (operation.workOrderNumber?.toLowerCase().contains(query) ?? false) ||
            (operation.batchNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _createNewPackingOperation() async {
    context.go('/operations/packing/create');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Packing Operations'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadOperations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewPackingOperation,
        icon: const Icon(Icons.add),
        label: const Text('New Packing'),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by reference, container, location, work order...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading packing operations...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOperations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredOperations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _operations.isEmpty
                  ? 'No packing operations found'
                  : 'No operations match your search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _operations.isEmpty
                  ? 'Create your first packing operation'
                  : 'Try a different search term',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOperations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredOperations.length,
        itemBuilder: (context, index) {
          final operation = _filteredOperations[index];
          return _buildOperationCard(operation);
        },
      ),
    );
  }

  void _navigateToDetail(PackingResponse operation) {
    if (operation.packingOperationId != null) {
      context.go('/operations/packing/${operation.packingOperationId}');
    }
  }

  Widget _buildOperationCard(PackingResponse operation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(operation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(operation.status ?? PackingStatus.failed),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (operation.status?.name ?? 'unknown').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (operation.packingOperationId != null)
                    Text(
                      'ID: ${operation.packingOperationId}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Reference
              Text(
                operation.packingReference ?? 'No Reference',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Container Info
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 16, color: Colors.brown),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Container: ${operation.parentContainerId ?? 'Unknown'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('Location: ${operation.packingLocationGLN ?? 'Unknown'}'),
                ],
              ),
              const SizedBox(height: 4),

              // Work Order / Batch
              if (operation.workOrderNumber != null || operation.batchNumber != null)
                Row(
                  children: [
                    if (operation.workOrderNumber != null) ...[
                      const Icon(Icons.work, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('WO: ${operation.workOrderNumber}'),
                      const SizedBox(width: 12),
                    ],
                    if (operation.batchNumber != null) ...[
                      const Icon(Icons.batch_prediction, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text('Batch: ${operation.batchNumber}'),
                    ],
                  ],
                ),
              const SizedBox(height: 8),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${operation.packedItemsCount ?? 0} items packed',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (operation.processedAt != null)
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(operation.processedAt!),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PackingStatus status) {
    switch (status) {
      case PackingStatus.success:
        return Colors.green;
      case PackingStatus.partialSuccess:
        return Colors.orange;
      case PackingStatus.failed:
        return Colors.red;
      case PackingStatus.validationError:
        return Colors.red[700]!;
    }
  }
}
