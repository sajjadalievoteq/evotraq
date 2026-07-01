import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/services/operations/shipping/shipping_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/shipping/cubit/shipping_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_list/utils/shipping_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_list/widgets/shipping_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_list/widgets/shipping_operation_list_results.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_list/widgets/shipping_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_list/widgets/shipping_record_info_section.dart';
import 'package:traqtrace_app/features/operations/shipping/utils/shipping_ui_constants.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Screen to list all shipping operations with search capabilities.
class ShippingOperationListScreen extends StatefulWidget {
  const ShippingOperationListScreen({
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
  State<ShippingOperationListScreen> createState() =>
      _ShippingOperationListScreenState();
}

class _ShippingOperationListScreenState extends State<ShippingOperationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _trackingFilterController =
      TextEditingController();
  final _scrollController = ScrollController();

  List<ShippingResponse> _operations = [];
  int _totalRecords = 0;
  List<ShippingResponse> _filteredOperations = [];
  String? _selectedStatus;
  String _sortBy = 'processedAt';
  String _sortDir = 'desc';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 0;
  bool _initialLoadDone = false;
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
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      return;
    }
    if (!widget.embedded) {
      _loadOperations();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _trackingFilterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    ShippingQuickFilterDialog.open(
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
        title: const Text(ShippingUiConstants.advancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return ShippingAdvancedFiltersPanel(
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
    return ShippingUiConstants.sortFieldLabels[_sortBy] ??
        ShippingUiConstants.sortFieldFallback;
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
      final shippingService = getIt<ShippingOperationService>();
      final page = await shippingService.getShippingOperationsPage(page: 0);
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
            'Could not load shipping operations. Check your connection and tap Retry.';
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
      final shippingService = getIt<ShippingOperationService>();
      final nextPage = _currentPage + 1;
      final page = await shippingService.getShippingOperationsPage(page: nextPage);
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
        .read<ShippingOperationsCubit>()
        .updateOperationIds(ids, isEmpty: ids.isEmpty);
  }

  void _filterOperations() {
    setState(() {
      _filteredOperations = ShippingOperationListFilter.apply(
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

  void _navigateToDetail(ShippingResponse operation) {
    final id = operation.navigableOperationId;
    if (id == null) return;
    if (widget.embedded && widget.onSelectOperation != null) {
      widget.onSelectOperation!(id);
    } else {
      context.go('${Constants.opShippingRoute}/$id');
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
                      hintText: ShippingUiConstants.listSearchHint,
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
                ShippingRecordInfoSection(
                  loadedRecords: _operations.length,
                  filteredRecords: _filteredOperations.length,
                  totalRecords: _totalRecords,
                ),
                const SizedBox(height: Constants.spacing),
                Gs1ListSortingControls(
                  label: ShippingUiConstants.sortByLine(
                    _sortFieldDisplayLabel(),
                    _sortDir == 'asc'
                        ? ShippingUiConstants.sortAscendingLabel
                        : ShippingUiConstants.sortDescendingLabel,
                  ),
                  sortOrder: _sortDir,
                  onToggleSortOrder: _toggleSortDirection,
                ),
              ],
            ),
          ),
        ],
      ),
      results: ShippingOperationListResults(
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
        title: const Text('Shipping Operation'),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: widget.onEmbeddedCreate != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.go(Constants.opShippingCreateRoute),
              label: TraqIcon(AppAssets.iconPlus),
            ),
      body: body,
    );
  }
}
