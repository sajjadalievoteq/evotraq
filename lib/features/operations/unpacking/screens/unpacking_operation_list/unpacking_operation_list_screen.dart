import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/data/services/operations/unpacking/unpacking_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_list/utils/unpacking_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_list/widgets/unpacking_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_list/widgets/unpacking_operation_list_results.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_list/widgets/unpacking_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_list/widgets/unpacking_record_info_section.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_ui_constants.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Screen to list all unpacking operations with search capabilities.
class UnpackingOperationListScreen extends StatefulWidget {
  const UnpackingOperationListScreen({
    super.key,
    this.embedded = false,
    this.onSelectOperation,
    this.selectedOperationId,
    this.onLoadingChanged,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedOperationId;
  final ValueChanged<bool>? onLoadingChanged;

  @override
  State<UnpackingOperationListScreen> createState() =>
      _UnpackingOperationListScreenState();
}

class _UnpackingOperationListScreenState extends State<UnpackingOperationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _containerFilterController =
      TextEditingController();
  final _scrollController = ScrollController();

  List<UnpackingResponse> _operations = [];
  int _totalRecords = 0;
  List<UnpackingResponse> _filteredOperations = [];
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
    _containerFilterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    UnpackingQuickFilterDialog.open(
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
        title: const Text(UnpackingUiConstants.advancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return UnpackingAdvancedFiltersPanel(
                containerController: _containerFilterController,
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
    return UnpackingUiConstants.sortFieldLabels[_sortBy] ??
        UnpackingUiConstants.sortFieldFallback;
  }

  void _clearAllFilters() {
    _searchController.clear();
    _containerFilterController.clear();
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
      final unpackingService = getIt<UnpackingOperationService>();
      final page = await unpackingService.getUnpackingOperationsPage(page: 0);
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
            'Could not load unpacking operations. Check your connection and tap Retry.';
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
      final unpackingService = getIt<UnpackingOperationService>();
      final nextPage = _currentPage + 1;
      final page = await unpackingService.getUnpackingOperationsPage(page: nextPage);
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

  void _filterOperations() {
    setState(() {
      _filteredOperations = UnpackingOperationListFilter.apply(
        operations: _operations,
        query: _searchController.text,
        statusFilter: _selectedStatus,
        containerFilter: _containerFilterController.text,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );
    });
  }

  void _navigateToDetail(UnpackingResponse operation) {
    final id = operation.navigableOperationId;
    if (id == null) return;
    if (widget.embedded && widget.onSelectOperation != null) {
      widget.onSelectOperation!(id);
    } else {
      context.go('${Constants.opUnpackingRoute}/$id');
    }
  }

  bool get _hasActiveAdvancedFilters =>
      _containerFilterController.text.isNotEmpty ||
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
                    _containerFilterController,
                  ]),
                  builder: (context, _) {
                    return Gs1ListSearchBar(
                      hintText: UnpackingUiConstants.listSearchHint,
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
                UnpackingRecordInfoSection(
                  loadedRecords: _operations.length,
                  filteredRecords: _filteredOperations.length,
                  totalRecords: _totalRecords,
                ),
                const SizedBox(height: Constants.spacing),
                Gs1ListSortingControls(
                  label: UnpackingUiConstants.sortByLine(
                    _sortFieldDisplayLabel(),
                    _sortDir == 'asc'
                        ? UnpackingUiConstants.sortAscendingLabel
                        : UnpackingUiConstants.sortDescendingLabel,
                  ),
                  sortOrder: _sortDir,
                  onToggleSortOrder: _toggleSortDirection,
                ),
              ],
            ),
          ),
        ],
      ),
      results: UnpackingOperationListResults(
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
        title: const Text('Unpacking Operation'),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Constants.opUnpackingCreateRoute),
        label: TraqIcon(AppAssets.iconPlus),
      ),
      body: body,
    );
  }
}
