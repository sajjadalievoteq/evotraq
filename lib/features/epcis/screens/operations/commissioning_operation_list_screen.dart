import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/operations/commissioning_models.dart';
import 'package:traqtrace_app/data/services/commissioning_operation_service.dart';
import 'package:intl/intl.dart';

/// Screen to list all commissioning operations with search and filter capabilities
class CommissioningOperationListScreen extends StatefulWidget {
  const CommissioningOperationListScreen({Key? key}) : super(key: key);

  @override
  State<CommissioningOperationListScreen> createState() =>
      _CommissioningOperationListScreenState();
}

class _CommissioningOperationListScreenState
    extends State<CommissioningOperationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CommissioningResponse> _operations = [];
  List<CommissioningResponse> _filteredOperations = [];
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
      final service = getIt<CommissioningOperationService>();
      final operations = await service.getCommissioningOperations();
      setState(() {
        _operations = operations;
        _filteredOperations = operations;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load commissioning operations: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterOperations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOperations = _operations.where((operation) {
        return (operation.commissioningReference?.toLowerCase().contains(
                  query,
                ) ??
                false) ||
            (operation.gtinCode?.toLowerCase().contains(query) ?? false) ||
            (operation.batchLotNumber?.toLowerCase().contains(query) ??
                false) ||
            (operation.commissioningLocationGLN?.toLowerCase().contains(
                  query,
                ) ??
                false) ||
            (operation.commissioningOperationId?.toLowerCase().contains(
                  query,
                ) ??
                false) ||
            (operation.itemDescription?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _navigateToDetail(CommissioningResponse operation) {
    if (operation.commissioningOperationId != null) {
      context.go(
        '/operations/commissioning/${operation.commissioningOperationId}',
      );
    }
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
        title: const Text('Commissioning Operations'),
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
        onPressed: () => context.go('/operations/commissioning/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Commissioning'),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by reference, GTIN, batch, location...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Content
          Expanded(child: _buildContent()),
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
            Text('Loading commissioning operations...'),
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
            Icon(Icons.play_for_work, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _operations.isEmpty
                  ? 'No commissioning operations found'
                  : 'No operations match your search',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _operations.isEmpty
                  ? 'Create your first commissioning operation'
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

  Widget _buildOperationCard(CommissioningResponse operation) {
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
              // Header with status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(operation.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(operation.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (operation.commissionedCount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        '${operation.commissionedCount} items',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Reference / Title - prefer item description if available
              Text(
                operation.itemDescription ??
                    operation.commissioningReference ??
                    (operation.gtinCode != null
                        ? 'GTIN: ${operation.gtinCode}'
                        : 'Commissioning Operation'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // GTIN Info
              if (operation.gtinCode != null)
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'GTIN: ${operation.gtinCode}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (operation.gtinCode != null) const SizedBox(height: 4),

              // Batch/Lot
              if (operation.batchLotNumber != null)
                Row(
                  children: [
                    const Icon(
                      Icons.batch_prediction,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 4),
                    Text('Batch: ${operation.batchLotNumber}'),
                  ],
                ),
              if (operation.batchLotNumber != null) const SizedBox(height: 4),

              // Location
              if (operation.commissioningLocationGLN != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Location: ${operation.commissioningLocationGLN}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // Footer with date and counts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${operation.commissionedCount ?? 0} commissioned',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (operation.failedCount != null &&
                          operation.failedCount! > 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.error, size: 14, color: Colors.red[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${operation.failedCount} failed',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (operation.processedAt != null)
                    Text(
                      DateFormat(
                        'MMM dd, yyyy HH:mm',
                      ).format(operation.processedAt!),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(CommissioningStatus? status) {
    if (status == null) return Colors.grey;
    switch (status) {
      case CommissioningStatus.success:
        return Colors.green;
      case CommissioningStatus.partialSuccess:
        return Colors.orange;
      case CommissioningStatus.failed:
        return Colors.red;
      case CommissioningStatus.validationError:
        return Colors.red[700]!;
    }
  }

  String _getStatusLabel(CommissioningStatus? status) {
    if (status == null) return 'UNKNOWN';
    switch (status) {
      case CommissioningStatus.success:
        return 'SUCCESS';
      case CommissioningStatus.partialSuccess:
        return 'PARTIAL';
      case CommissioningStatus.failed:
        return 'FAILED';
      case CommissioningStatus.validationError:
        return 'INVALID';
    }
  }
}
