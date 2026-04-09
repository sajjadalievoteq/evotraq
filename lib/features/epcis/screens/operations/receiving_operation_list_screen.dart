import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/operations/receiving_models.dart';
import 'package:traqtrace_app/features/epcis/services/operations/receiving_operation_service.dart';

/// Screen to list all receiving operations with search and filter capabilities
class ReceivingOperationListScreen extends StatefulWidget {
  const ReceivingOperationListScreen({Key? key}) : super(key: key);

  @override
  State<ReceivingOperationListScreen> createState() => _ReceivingOperationListScreenState();
}

class _ReceivingOperationListScreenState extends State<ReceivingOperationListScreen> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  List<ReceivingResponse> _operations = [];
  List<ReceivingResponse> _filteredOperations = [];
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
      final receivingService = getIt<ReceivingOperationService>();
      final operations = await receivingService.getAllReceivingOperations();
      setState(() {
        _operations = operations;
        _filteredOperations = operations;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load receiving operations: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterOperations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOperations = _operations.where((operation) {
        return (operation.receivingReference?.toLowerCase().contains(query) ?? false) ||
            (operation.receivingGLN?.toLowerCase().contains(query) ?? false) ||
            (operation.sourceGLN?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _createNewReceivingOperation() async {
    // Use go_router for consistent web navigation
    context.go('/operations/receiving/create');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        title: const Text('Receiving Operations'),
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
        onPressed: _createNewReceivingOperation,
        icon: const Icon(Icons.add),
        label: const Text('New Receipt'),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by reference, receiving location, or source...',
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
            Text('Loading receiving operations...'),
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
              Icons.move_to_inbox,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _operations.isEmpty
                  ? 'No receiving operations found'
                  : 'No operations match your search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _operations.isEmpty
                  ? 'Create your first receiving operation'
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

  void _navigateToDetail(ReceivingResponse operation) {
    if (operation.receivingOperationId != null) {
      context.go('/operations/receiving/${operation.receivingOperationId}');
    }
  }

  Widget _buildOperationCard(ReceivingResponse operation) {
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
                    color: _getStatusColor(operation.status ?? ReceivingStatus.failed),
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
                if (operation.receivingOperationId != null)
                  Text(
                    'ID: ${operation.receivingOperationId}',
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
              operation.receivingReference ?? 'No Reference',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Locations
            Row(
              children: [
                const Icon(Icons.flight_takeoff, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text('From: ${operation.sourceGLN ?? 'Unknown'}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.flight_land, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text('To: ${operation.receivingGLN ?? 'Unknown'}'),
              ],
            ),
            const SizedBox(height: 8),

            // Footer
            Row(
              children: [
                Icon(Icons.inventory_2, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${operation.processedEpcsCount ?? operation.epcList?.length ?? 0} items',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                if (operation.processedAt != null)
                  Text(
                    _formatDate(operation.processedAt!),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Color _getStatusColor(ReceivingStatus status) {
    switch (status) {
      case ReceivingStatus.success:
        return Colors.green;
      case ReceivingStatus.partialSuccess:
        return Colors.orange;
      case ReceivingStatus.failed:
        return Colors.red;
      case ReceivingStatus.validationError:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
