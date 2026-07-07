import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_mapper.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/utils/commissioning_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card_builders.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_results.dart';

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
  final TextEditingController _gtinFilterController = TextEditingController();

  late OperationsCubit<Operation> _cubit;
  String _sortBy = 'createdAt';
  String _sortDir = 'desc';
  int _pageSize = 25;

  @override
  void initState() {
    super.initState();
    _cubit = _buildCubit()..loadInitial();
  }

  @override
  void dispose() {
    _cubit.close();
    _gtinFilterController.dispose();
    super.dispose();
  }

  OperationsCubit<Operation> _buildCubit() {
    return OperationsCubit<Operation>(
      pageSize: _pageSize,
      loadErrorMessage:
          'Failed to load commissioning operations. Check your connection and tap Retry.',
      loadMoreErrorMessage:
          'Could not load more operations. Check your connection and try again.',
      fetchList: ({required int page, required int size}) async {
        final gtinFilter = _gtinFilterController.text.trim();
        final result = await getIt<CommissioningOperationService>().listBatches(
          page: page,
          size: size,
          gtin: gtinFilter.isEmpty ? null : gtinFilter,
          sortBy: _sortBy,
          sortDir: _sortDir,
        );
        return OperationPage<Operation>(
          operations: result.batches
              .map(OperationMapper.fromCommissioningBatch)
              .toList(),
          page: page,
          size: size,
          count: result.batches.length,
          total: result.batches.length,
          totalPages: result.isLast ? page + 1 : page + 2,
        );
      },
    );
  }

  void _reloadFromServer() {
    _cubit.refresh();
  }

  void _onPageSizeChanged(int newSize) {
    if (_pageSize == newSize) return;
    setState(() {
      _pageSize = newSize;
      _cubit.close();
      _cubit = _buildCubit();
    });
    _cubit.loadInitial();
  }

  void _onServerSortChanged({String? sortBy, String? sortDir}) {
    setState(() {
      if (sortBy != null) _sortBy = sortBy;
      if (sortDir != null) _sortDir = sortDir;
    });
    _reloadFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _CommissioningOperationListBody(
        embedded: widget.embedded,
        onSelectOperation: widget.onSelectOperation,
        selectedBatchId: widget.selectedBatchId,
        onLoadingChanged: widget.onLoadingChanged,
        gtinFilterController: _gtinFilterController,
        sortBy: _sortBy,
        sortDir: _sortDir,
        pageSize: _pageSize,
        onServerSortChanged: _onServerSortChanged,
        onPageSizeChanged: _onPageSizeChanged,
        onServerReload: _reloadFromServer,
      ),
    );
  }
}

class _CommissioningOperationListBody extends StatefulWidget {
  const _CommissioningOperationListBody({
    required this.embedded,
    required this.gtinFilterController,
    required this.sortBy,
    required this.sortDir,
    required this.pageSize,
    required this.onServerSortChanged,
    required this.onPageSizeChanged,
    required this.onServerReload,
    this.onSelectOperation,
    this.selectedBatchId,
    this.onLoadingChanged,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedBatchId;
  final ValueChanged<bool>? onLoadingChanged;
  final TextEditingController gtinFilterController;
  final String sortBy;
  final String sortDir;
  final int pageSize;
  final void Function({String? sortBy, String? sortDir}) onServerSortChanged;
  final ValueChanged<int> onPageSizeChanged;
  final VoidCallback onServerReload;

  @override
  State<_CommissioningOperationListBody> createState() =>
      _CommissioningOperationListBodyState();
}

class _CommissioningOperationListBodyState
    extends State<_CommissioningOperationListBody> {
  final TextEditingController _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onFiltersChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFiltersChanged() => setState(() {});

  void _filterOperations() => setState(() {});

  List<Operation> _filteredOperations(List<Operation> operations) {
    return CommissioningOperationListFilter.applyToOperations(
      operations: operations,
      query: _searchController.text,
      statusFilter: _selectedStatus,
    );
  }

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
    var dialogSortBy = widget.sortBy;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(CommissioningUiConstants.advancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return CommissioningAdvancedFiltersPanel(
                gtinController: widget.gtinFilterController,
                sortBy: dialogSortBy,
                onSortByChanged: (value) {
                  if (value != null) {
                    setLocalState(() => dialogSortBy = value);
                  }
                },
                onApply: () {
                  Navigator.of(dialogContext).pop();
                  widget.onServerSortChanged(sortBy: dialogSortBy);
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

  String _sortFieldDisplayLabel() {
    return CommissioningUiConstants.sortFieldLabels[widget.sortBy] ??
        CommissioningUiConstants.sortFieldFallback;
  }

  void _clearAllFilters() {
    _searchController.clear();
    widget.gtinFilterController.clear();
    setState(() => _selectedStatus = null);
    widget.onServerSortChanged(sortBy: 'createdAt', sortDir: 'desc');
    widget.onServerReload();
  }

  void _navigateToDetail(Operation operation) {
    final id = operation.navigableOperationId;
    if (id == null) return;
    if (widget.embedded) {
      widget.onSelectOperation?.call(id);
    } else {
      context.go('${Constants.opCommissioningRoute}/$id');
    }
  }

  bool get _hasActiveFilters =>
      _selectedStatus != null ||
      widget.gtinFilterController.text.isNotEmpty ||
      widget.sortBy != 'createdAt' ||
      widget.sortDir != 'desc';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationsCubit<Operation>, OperationsState<Operation>>(
      listener: (context, state) {
        widget.onLoadingChanged?.call(state.isLoading);

        if (widget.embedded &&
            widget.selectedBatchId == null &&
            !state.isLoading &&
            state.errorMessage == null) {
          final filtered = _filteredOperations(state.items);
          if (filtered.isNotEmpty) {
            final firstId = filtered.first.navigableOperationId;
            if (firstId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onSelectOperation?.call(firstId);
              });
            }
          }
        }
      },
      builder: (context, state) {
        final filtered = _filteredOperations(state.items);
        final cubit = context.read<OperationsCubit<Operation>>();

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
                        widget.gtinFilterController,
                      ]),
                      builder: (context, _) {
                        return Gs1ListSearchBar(
                          hintText: CommissioningUiConstants.listSearchHint,
                          controller: _searchController,
                          showAdvancedFilters:
                              widget.gtinFilterController.text.isNotEmpty ||
                                  _selectedStatus != null ||
                                  widget.sortBy != 'createdAt' ||
                                  widget.sortDir != 'desc',
                          onSearch: _filterOperations,
                          onQueryChanged: (_) => _filterOperations(),
                          onRefresh: widget.onServerReload,
                          onQuickFilters: _showFilterDialog,
                          onToggleAdvancedFilters: _showAdvancedFiltersDialog,
                          onClear: () {
                            _searchController.clear();
                            _filterOperations();
                          },
                          sortTooltip: CommissioningUiConstants.sortByLine(
                            _sortFieldDisplayLabel(),
                            widget.sortDir == 'asc'
                                ? CommissioningUiConstants.sortAscendingLabel
                                : CommissioningUiConstants.sortDescendingLabel,
                          ),
                          sortOrder: widget.sortDir,
                          onSortOrderChanged: (order) {
                            if (widget.sortDir != order) {
                              widget.onServerSortChanged(sortDir: order);
                            }
                          },
                          pageSize: widget.pageSize,
                          pageSizeOptions:
                              CommissioningUiConstants.pageSizeOptions,
                          onPageSizeChanged: widget.onPageSizeChanged,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          results: OperationListResults<Operation>(
            scrollController: _scrollController,
            isLoading: state.isLoading,
            errorMessage: state.errorMessage,
            operations: state.items,
            filteredOperations: filtered,
            hasActiveFilters: _hasActiveFilters,
            onRetry: cubit.refresh,
            onRefresh: cubit.refresh,
            onClearFilters: _clearAllFilters,
            emptyTitle: 'No commissioning operations found',
            emptySubtitle: 'Create your first commissioning operation',
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            onLoadMore: cubit.loadMore,
            itemBuilder: (context, operation) =>
                OperationListCardBuilders.forOperation(
              operation: operation,
              isSelected: widget.embedded &&
                  operation.navigableOperationId != null &&
                  operation.navigableOperationId == widget.selectedBatchId,
              onTap: () => _navigateToDetail(operation),
            ),
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
            onPressed: () => context.go(Constants.opCommissioningNewRoute),
            icon: TraqIcon(AppAssets.iconPlus),
            label: const Text('New Commissioning'),
          ),
          body: body,
        );
      },
    );
  }
}
