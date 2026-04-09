import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/cubit/shipping_operation_cubit.dart';
import 'package:traqtrace_app/features/epcis/models/operations/shipping_models.dart';

/// Screen to list all shipping operations with search and filter capabilities
class ShippingOperationListScreen extends StatefulWidget {
  const ShippingOperationListScreen({Key? key}) : super(key: key);

  @override
  State<ShippingOperationListScreen> createState() =>
      _ShippingOperationListScreenState();
}

class _ShippingOperationListScreenState
    extends State<ShippingOperationListScreen>
    with RouteAware {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterOperations);
    context.read<ShippingOperationCubit>().loadOperations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload operations when navigating back to this screen
    context.read<ShippingOperationCubit>().loadOperations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOperations() {
    setState(() {});
  }

  Future<void> _createNewShippingOperation() async {
    // Use go_router for consistent web navigation
    context.go('/operations/shipping/create');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShippingOperationCubit, ShippingOperationState>(
      builder: (context, state) {
        final query = _searchController.text.toLowerCase();
        final filteredOperations = state.operations.where((operation) {
          return (operation.shippingReference?.toLowerCase().contains(query) ??
                  false) ||
              (operation.sourceGLN?.toLowerCase().contains(query) ?? false) ||
              (operation.destinationGLN?.toLowerCase().contains(query) ??
                  false);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text('Shipping Operations'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () =>
                    context.read<ShippingOperationCubit>().loadOperations(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          drawer: const AppDrawer(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _createNewShippingOperation,
            icon: const Icon(Icons.add),
            label: const Text('New Shipment'),
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by reference, source, or destination...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(child: _buildContent(state, filteredOperations)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    ShippingOperationState state,
    List<ShippingResponse> filteredOperations,
  ) {
    if (state.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading shipping operations...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load shipping operations: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<ShippingOperationCubit>().loadOperations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredOperations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              state.operations.isEmpty
                  ? 'No shipping operations found'
                  : 'No operations match your search',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              state.operations.isEmpty
                  ? 'Create your first shipping operation'
                  : 'Try a different search term',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ShippingOperationCubit>().loadOperations(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOperations.length,
        itemBuilder: (context, index) {
          final operation = filteredOperations[index];
          return _buildOperationCard(operation);
        },
      ),
    );
  }

  void _navigateToDetail(ShippingResponse operation) {
    if (operation.shippingOperationId != null) {
      context.go('/operations/shipping/${operation.shippingOperationId}');
    }
  }

  Widget _buildOperationCard(ShippingResponse operation) {
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        operation.status ?? ShippingStatus.failed,
                      ),
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
                  if (operation.shippingOperationId != null)
                    Text(
                      'ID: ${operation.shippingOperationId}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Reference
              Text(
                operation.shippingReference ?? 'No Reference',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Locations
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('From: ${operation.sourceGLN ?? 'Unknown'}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_off, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('To: ${operation.destinationGLN ?? 'Unknown'}'),
                ],
              ),
              const SizedBox(height: 8),

              // Items count
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('${operation.processedEpcsCount ?? 0} items processed'),
                  const Spacer(),
                  if (operation.eventIds?.isNotEmpty ?? false)
                    Text(
                      '${operation.eventIds!.length} events created',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),

              // Messages if any
              if (operation.messages?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: operation.hasErrors
                        ? Colors.red[50]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: operation.messages!
                        .map(
                          (message) => Row(
                            children: [
                              Icon(
                                operation.hasErrors
                                    ? Icons.error_outline
                                    : Icons.info_outline,
                                size: 16,
                                color: operation.hasErrors
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    color: operation.hasErrors
                                        ? Colors.red[800]
                                        : Colors.blue[800],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              // View details hint
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.success:
        return Colors.green;
      case ShippingStatus.partialSuccess:
        return Colors.orange;
      case ShippingStatus.failed:
        return Colors.red;
      case ShippingStatus.validationError:
        return Colors.orange;
    }
  }
}
