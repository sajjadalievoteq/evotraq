import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:intl/intl.dart';
import 'package:world_countries/helpers.dart';

/// Screen to list all commissioning operations with search and infinite scroll.
///
/// [embedded] = true  → no Scaffold/AppBar/Drawer/FAB; used inside the split-view.
/// [onSelectOperation] → called when a card is tapped in embedded mode.
/// [selectedBatchId]   → highlights the currently-selected card.
class CommissioningOperationListScreen extends StatefulWidget {
  const CommissioningOperationListScreen({
    Key? key,
    this.embedded = false,
    this.onSelectOperation,
    this.selectedBatchId,
    this.onLoadingChanged,
  }) : super(key: key);

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedBatchId;

  /// Called whenever the list loading state changes (true = started, false = done).
  final ValueChanged<bool>? onLoadingChanged;

  @override
  State<CommissioningOperationListScreen> createState() =>
      _CommissioningOperationListScreenState();
}

class _CommissioningOperationListScreenState
    extends State<CommissioningOperationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;

  List<CommissioningBatch> _operations = [];
  List<CommissioningBatch> _filteredOperations = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchController.addListener(_filterOperations);
    _loadOperations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadOperations() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 0;
      _hasMore = true;
    });
    widget.onLoadingChanged?.call(true);
    try {
      final service = getIt<CommissioningOperationService>();
      final result = await service.listBatches(page: 0, size: _pageSize);
      setState(() {
        _operations = result.batches;
        _hasMore = !result.isLast;
        _currentPage = 0;
      });
      _filterOperations();
      // Auto-select the first item on initial load in embedded/split-view mode.
      if (widget.embedded &&
          widget.selectedBatchId == null &&
          result.batches.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSelectOperation?.call(result.batches.first.batchId);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load commissioning operations: $e';
      });
    } finally {
      setState(() => _isLoading = false);
      widget.onLoadingChanged?.call(false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    setState(() => _isLoadingMore = true);
    try {
      final service = getIt<CommissioningOperationService>();
      final nextPage = _currentPage + 1;
      final result = await service.listBatches(page: nextPage, size: _pageSize);
      setState(() {
        _operations.addAll(result.batches);
        _hasMore = !result.isLast;
        _currentPage = nextPage;
      });
      _filterOperations();
    } catch (e) {
      debugPrint('CommissioningListScreen: Error loading more: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void _filterOperations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOperations = _operations.where((op) {
        return (op.commissioningReference?.toLowerCase().contains(query) ??
                false) ||
            (op.gtinCode?.toLowerCase().contains(query) ?? false) ||
            (op.batchLotNumber?.toLowerCase().contains(query) ?? false) ||
            (op.commissioningLocationGLN?.toLowerCase().contains(query) ??
                false) ||
            op.batchId.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToDetail(CommissioningBatch op) {
    if (widget.embedded) {
      widget.onSelectOperation?.call(op.batchId);
    } else {
      context.go('/operations/commissioning/${op.batchId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        // Search bar
        Container(
          padding: EdgeInsets.only(top: context.horizontalPadding.left,left: context.horizontalPadding.left,right: context.horizontalPadding.left,bottom: 16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by reference, GTIN, lot number, location...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        // Content
        Expanded(child: _buildContent()),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Commissioning'),
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
      body: body,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return AppShimmer(
        child: ListView.builder(
          padding: EdgeInsets.all(context.horizontalPadding.left),
          itemCount: 6,
          itemBuilder: (context, _) => _CommissioningListItemSkeleton(context),
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

    if (_filteredOperations.isEmpty && !_isLoadingMore) {
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
        controller: _scrollController,
        padding: context.horizontalPadding,
        itemCount: _filteredOperations.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredOperations.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final op = _filteredOperations[index];
          return _buildOperationCard(op);
        },
      ),
    );
  }

  Widget _buildOperationCard(CommissioningBatch op) {
    final isSelected =
        widget.embedded && op.batchId == widget.selectedBatchId;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2 ,

      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : null,
      child: InkWell(
        onTap: () => _navigateToDetail(op),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: status badge + commissioned count
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(op.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(op.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
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
                      '${op.totalCommissioned} items',
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

              // Title: reference or GTIN
              Text(
                op.commissioningReference ??
                    (op.gtinCode != null
                        ? 'GTIN: ${op.gtinCode}'
                        : 'Commissioning Operation'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected?Colors.white:null
                ),
              ),
              const SizedBox(height: 8),

              // GTIN
              if (op.gtinCode != null)
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
                        'GTIN: ${op.gtinCode}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isSelected?Colors.white:null
                        ),
                      ),
                    ),
                  ],
                ),
              if (op.gtinCode != null) const SizedBox(height: 4),

              // Lot number
              if (op.batchLotNumber != null)
                Row(
                  children: [
                    const Icon(
                      Icons.numbers,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 4),
                    Text('Lot #: ${op.batchLotNumber}',  style: TextStyle(
                        color: isSelected?Colors.white:null
                    ),),
                  ],
                ),
              if (op.batchLotNumber != null) const SizedBox(height: 4),

              // Location
              if (op.commissioningLocationGLN != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Location: ${op.commissioningLocationGLN}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isSelected?Colors.white:null
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // Footer: counts + date
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
                        '${op.totalCommissioned} commissioned',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (op.totalFailed > 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.error, size: 14, color: Colors.red[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${op.totalFailed} failed',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (op.createdAt != null)
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(op.createdAt!),
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

  Color _getStatusColor(CommissioningBatchStatus status) {
    switch (status) {
      case CommissioningBatchStatus.success:
        return Colors.green;
      case CommissioningBatchStatus.partialSuccess:
        return Colors.orange;
      case CommissioningBatchStatus.failed:
        return Colors.red;
      case CommissioningBatchStatus.pending:
        return Colors.blue;
      case CommissioningBatchStatus.inProgress:
        return Colors.teal;
    }
  }

  String _getStatusLabel(CommissioningBatchStatus status) {
    switch (status) {
      case CommissioningBatchStatus.success:
        return 'SUCCESS';
      case CommissioningBatchStatus.partialSuccess:
        return 'PARTIAL';
      case CommissioningBatchStatus.failed:
        return 'FAILED';
      case CommissioningBatchStatus.pending:
        return 'PENDING';
      case CommissioningBatchStatus.inProgress:
        return 'IN PROGRESS';
    }
  }
}

// ---------------------------------------------------------------------------
// Skeleton helpers (used while loading)
// ---------------------------------------------------------------------------

Widget _CommissioningListItemSkeleton(BuildContext context) {
  final base = AppShimmer.defaultBaseColor(context);
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: base.withOpacity(0.3),
      borderRadius: BorderRadius.circular(2),
      border: Border.all(color: base),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status chip + count chip row
        Row(
          children: [
            Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const Spacer(),
            Container(
              width: 64,
              height: 24,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Title line
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        // Sub-line (GTIN)
        Container(
          height: 13,
          width: 200,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        // Bottom row
        Row(
          children: [
            Container(
              height: 13,
              width: 120,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const Spacer(),
            Container(
              height: 13,
              width: 90,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
