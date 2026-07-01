import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/data/services/operations/return_receiving/return_receiving_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/return_receiving/cubit/return_receiving_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_list/utils/return_receiving_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_list/widgets/return_receiving_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_list/widgets/return_receiving_operation_list_results.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_list/widgets/return_receiving_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_list/widgets/return_receiving_record_info_section.dart';
import 'package:traqtrace_app/features/operations/return_receiving/utils/return_receiving_ui_constants.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Screen to list all ReturnReceiving operations with search capabilities.
class ReturnReceivingOperationListScreen extends StatefulWidget {
  const ReturnReceivingOperationListScreen({
    super.key,
    this.embedded = false,
    this.onSelectOperation,
    this.selectedOperationId,
    this.onLoadingChanged,
    this.onBindRefresh,
    this.onEmbeddedCreate,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedOperationId;
  final ValueChanged<bool>? onLoadingChanged;
  final void Function(VoidCallback refreshFn)? onBindRefresh;
  final VoidCallback? onEmbeddedCreate;

  @override
  State<ReturnReceivingOperationListScreen> createState() =>
      _ReturnReceivingOperationListScreenState();
}

class _ReturnReceivingOperationListScreenState extends State<ReturnReceivingOperationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _trackingFilterController =
      TextEditingController();
  final _scrollController = ScrollController();

  List<ReturnReceivingResponse> _operations = [];
  int _totalRecords = 0;
  List<ReturnReceivingResponse> _filteredOperations = [];
  String? _selectedStatus;
  String _sortBy = 'processedAt';
  String _sortDir = 'desc';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterOperations);
    _loadOperations();
    widget.onBindRefresh?.call(_loadOperations);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _trackingFilterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    ReturnReceivingQuickFilterDialog.open(
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
        title: const Text(ReturnReceivingUiConstants.advancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return ReturnReceivingAdvancedFiltersPanel(
                trackingController: _trackingFilterController,
                sortBy: _sortBy,
                onSortByChanged: (value) {
                  if (value != null) {
                    setLocalState(() => _sortBy = value);
                  }
                },
                onApply: () {
                  Navigator.of(dialogContext).pop();
                  setState(() {});
                  _filterOperations();
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
    _filterOperations();
  }

  String _sortFieldDisplayLabel() {
    return ReturnReceivingUiConstants.sortFieldLabels[_sortBy] ??
        ReturnReceivingUiConstants.sortFieldFallback;
  }

  void _clearAllFilters() {
    _searchController.clear();
    _trackingFilterController.clear();
    setState(() {
      _selectedStatus = null;
      _sortBy = 'processedAt';
      _sortDir = 'desc';
    });
    _filterOperations();
  }

  Future<void> _loadOperations() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 0;
    });
    widget.onLoadingChanged?.call(true);

    try {
      final receivingService = getIt<ReturnReceivingOperationService>();
      final page = await receivingService.getReturnReceivingOperationsPage(page: 0);
      setState(() {
        _operations = page.operations;
        _totalRecords = page.total;
        _hasMore = page.totalPages > 1;
      });
      _filterOperations();
      if (widget.embedded &&
          widget.selectedOperationId == null &&
          _filteredOperations.isNotEmpty) {
        final firstId = _filteredOperations.first.navigableOperationId;
        if (firstId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onSelectOperation?.call(firstId);
          });
        }
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.getUserFriendlyMessage();
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Could not load ReturnReceiving operations. Check your connection and tap Retry.';
      });
    } finally {
      setState(() => _isLoading = false);
      widget.onLoadingChanged?.call(false);
    }
  }

  Future<void> _loadMoreOperations() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final receivingService = getIt<ReturnReceivingOperationService>();
      final nextPage = _currentPage + 1;
      final page = await receivingService.getReturnReceivingOperationsPage(page: nextPage);
      setState(() {
        _operations = [..._operations, ...page.operations];
        _totalRecords = page.total;
        _currentPage = nextPage;
        _hasMore = nextPage + 1 < page.totalPages;
      });
      _filterOperations();
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.getUserFriendlyMessage();
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Could not load more operations. Check your connection and try again.';
      });
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void _syncEmbeddedOperationIds() {
    if (!widget.embedded) return;
    final ids = _filteredOperations
        .map((op) => op.navigableOperationId)
        .whereType<String>()
        .toList();
    context
        .read<ReturnReceivingOperationsCubit>()
        .updateOperationIds(ids, isEmpty: ids.isEmpty);
  }

  void _filterOperations() {
    setState(() {
      _filteredOperations = ReturnReceivingOperationListFilter.apply(
        operations: _operations,
        query: _searchController.text,
        statusFilter: _selectedStatus,
        trackingFilter: _trackingFilterController.text,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );
    });
    _syncEmbeddedOperationIds();
  }

  void _navigateToDetail(ReturnReceivingResponse operation) {
    final id = operation.navigableOperationId;
    if (id == null) return;
    if (widget.embedded && widget.onSelectOperation != null) {
      widget.onSelectOperation!(id);
    } else {
      context.go('${Constants.opReturnReceivingRoute}/$id');
    }
  }

  bool get _hasActiveAdvancedFilters =>
      _trackingFilterController.text.isNotEmpty ||
      _sortBy != 'processedAt' ||
      _sortDir != 'desc';

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
                    _trackingFilterController,
                  ]),
                  builder: (context, _) {
                    return Gs1ListSearchBar(
                      hintText: ReturnReceivingUiConstants.listSearchHint,
                      controller: _searchController,
                      showAdvancedFilters: _hasActiveAdvancedFilters ||
                          _selectedStatus != null,
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
                ReturnReceivingRecordInfoSection(
                  loadedRecords: _operations.length,
                  filteredRecords: _filteredOperations.length,
                  totalRecords: _totalRecords,
                ),
                const SizedBox(height: Constants.spacing),
                Gs1ListSortingControls(
                  label: ReturnReceivingUiConstants.sortByLine(
                    _sortFieldDisplayLabel(),
                    _sortDir == 'asc'
                        ? ReturnReceivingUiConstants.sortAscendingLabel
                        : ReturnReceivingUiConstants.sortDescendingLabel,
                  ),
                  sortOrder: _sortDir,
                  onToggleSortOrder: _toggleSortDirection,
                ),
              ],
            ),
          ),
        ],
      ),
      results: ReturnReceivingOperationListResults(
        scrollController: _scrollController,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        operations: _operations,
        filteredOperations: _filteredOperations,
        hasActiveFilters:
            _selectedStatus != null || _hasActiveAdvancedFilters,
        embedded: widget.embedded,
        selectedOperationId: widget.selectedOperationId,
        onRetry: _loadOperations,
        onRefresh: _loadOperations,
        onClearFilters: _clearAllFilters,
        onOperationTap: _navigateToDetail,
        hasMore: _hasMore,
        isLoadingMore: _isLoadingMore,
        onLoadMore: _loadMoreOperations,
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text('Return Receiving'),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: widget.onEmbeddedCreate != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.go(Constants.opReturnReceivingCreateRoute),
              label: TraqIcon(AppAssets.iconPlus),
            ),
      body: body,
    );
  }
}
