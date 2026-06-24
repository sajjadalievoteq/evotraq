import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_operation_list_results.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_record_info_section.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_ui_constants.dart';

class CommissioningOperationListScreen extends StatefulWidget {
  const CommissioningOperationListScreen({
    super.key,
    this.embedded = false,
    this.onSelectOperation,
    this.selectedBatchId,
    this.onLoadingChanged,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedBatchId;
  final ValueChanged<bool>? onLoadingChanged;

  @override
  State<CommissioningOperationListScreen> createState() =>
      _CommissioningOperationListScreenState();
}

class _CommissioningOperationListScreenState
    extends State<CommissioningOperationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _gtinFilterController = TextEditingController();
  late final ScrollController _scrollController;

  List<CommissioningBatch> _operations = [];
  List<CommissioningBatch> _filteredOperations = [];
  String? _selectedStatus;
  String _sortBy = 'createdAt';
  String _sortDir = 'desc';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  int _pageSize = 25;
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
    _gtinFilterController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedStatus != null ||
      _gtinFilterController.text.isNotEmpty ||
      _sortBy != 'createdAt' ||
      _sortDir != 'desc';

  void _showFilterDialog() {
    CommissioningQuickFilterDialog.open(
      context,
      selectedStatus: _selectedStatus,
    ).then((result) {
      if (result == null) return;
      setState(() {
        _selectedStatus = result.cleared ? null : result.status;
      });
      _filterOperations();
    });
  }

  void _showAdvancedFiltersDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(CommissioningUiConstants.advancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return CommissioningAdvancedFiltersPanel(
                gtinController: _gtinFilterController,
                sortBy: _sortBy,
                onSortByChanged: (value) {
                  if (value != null) {
                    setLocalState(() => _sortBy = value);
                  }
                },
                onApply: () {
                  Navigator.of(dialogContext).pop();
                  setState(() {});
                  _loadOperations();
                },
                onClearAll: () {
                  Navigator.of(dialogContext).pop();
                  _clearAllFilters();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _toggleSortDirection() {
    setState(() {
      _sortDir = _sortDir == 'asc' ? 'desc' : 'asc';
    });
    _loadOperations();
  }

  String _sortFieldDisplayLabel() {
    return CommissioningUiConstants.sortFieldLabels[_sortBy] ??
        CommissioningUiConstants.sortFieldFallback;
  }

  void _clearAllFilters() {
    _searchController.clear();
    _gtinFilterController.clear();
    setState(() {
      _selectedStatus = null;
      _sortBy = 'createdAt';
      _sortDir = 'desc';
    });
    _loadOperations();
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
      final gtinFilter = _gtinFilterController.text.trim();
      final result = await service.listBatches(
        page: 0,
        size: _pageSize,
        gtin: gtinFilter.isEmpty ? null : gtinFilter,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );
      setState(() {
        _operations = result.batches;
        _hasMore = !result.isLast;
        _currentPage = 0;
      });
      _filterOperations();
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
      final gtinFilter = _gtinFilterController.text.trim();
      final result = await service.listBatches(
        page: nextPage,
        size: _pageSize,
        gtin: gtinFilter.isEmpty ? null : gtinFilter,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );
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
        if (_selectedStatus != null && op.status.name != _selectedStatus) {
          return false;
        }
        if (query.isEmpty) return true;
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
    final body = Gs1MasterListBody(
      toolbar: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: context.horizontalPadding.left,
              left: context.horizontalPadding.left,
              right: context.horizontalPadding.left,
            ),
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: Listenable.merge([
                    _searchController,
                    _gtinFilterController,
                  ]),
                  builder: (context, _) {
                    return Gs1ListSearchBar(
                      hintText: CommissioningUiConstants.listSearchHint,
                      controller: _searchController,
                      showAdvancedFilters:
                          _gtinFilterController.text.isNotEmpty ||
                              _selectedStatus != null ||
                              _sortBy != 'createdAt' ||
                              _sortDir != 'desc',
                      onSearch: _filterOperations,
                      onQueryChanged: (_) => _filterOperations(),
                      onRefresh: _loadOperations,
                      onQuickFilters: _showFilterDialog,
                      onToggleAdvancedFilters: _showAdvancedFiltersDialog,
                      onClear: () {
                        _searchController.clear();
                        _filterOperations();
                      },
                    );
                  },
                ),
                CommissioningRecordInfoSection(
                  loadedRecords: _operations.length,
                  hasMoreData: _hasMore,
                  pageSize: _pageSize,
                  onPageSizeChanged: (newSize) {
                    setState(() => _pageSize = newSize);
                    _loadOperations();
                  },
                ),
                const SizedBox(height: Constants.spacing),
                Gs1ListSortingControls(
                  label: CommissioningUiConstants.sortByLine(
                    _sortFieldDisplayLabel(),
                    _sortDir == 'asc'
                        ? CommissioningUiConstants.sortAscendingLabel
                        : CommissioningUiConstants.sortDescendingLabel,
                  ),
                  sortOrder: _sortDir,
                  onToggleSortOrder: _toggleSortDirection,
                ),
              ],
            ),
          ),
        ],
      ),
      results: CommissioningOperationListResults(
        isLoading: _isLoading,
        isLoadingMore: _isLoadingMore,
        errorMessage: _errorMessage,
        operations: _operations,
        filteredOperations: _filteredOperations,
        hasActiveFilters: _hasActiveFilters,
        embedded: widget.embedded,
        selectedBatchId: widget.selectedBatchId,
        scrollController: _scrollController,
        onRetry: _loadOperations,
        onRefresh: _loadOperations,
        onClearFilters: _clearAllFilters,
        onOperationTap: _navigateToDetail,
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text('Commissioning'),
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
}
