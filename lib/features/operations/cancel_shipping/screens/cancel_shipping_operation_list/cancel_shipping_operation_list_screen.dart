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
import 'package:traqtrace_app/data/services/operations/cancel_shipping/cancel_shipping_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_list/utils/cancel_shipping_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_list/widgets/cancel_shipping_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_list/widgets/cancel_shipping_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/utils/cancel_shipping_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card_builders.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_results.dart';

class CancelShippingOperationListScreen extends StatelessWidget {
  const CancelShippingOperationListScreen({
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperationsCubit<Operation>(
        loadErrorMessage:
            'Could not load shipping operations. Check your connection and tap Retry.',
        loadMoreErrorMessage:
            'Could not load more operations. Check your connection and try again.',
        fetchList: ({required int page, required int size}) async {
          final pageResult = await getIt<CancelShippingOperationService>()
              .getCancelShippingOperationsPage(page: page, size: size);
          return pageResult.map((r) => r.toOperation());
        },
      )..loadInitial(),
      child: _CancelShippingOperationListBody(
        embedded: embedded,
        onSelectOperation: onSelectOperation,
        selectedOperationId: selectedOperationId,
        onLoadingChanged: onLoadingChanged,
        onBindRefresh: onBindRefresh,
        onEmbeddedCreate: onEmbeddedCreate,
      ),
    );
  }
}

class _CancelShippingOperationListBody extends StatefulWidget {
  const _CancelShippingOperationListBody({
    required this.embedded,
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
  State<_CancelShippingOperationListBody> createState() =>
      _CancelShippingOperationListBodyState();
}

class _CancelShippingOperationListBodyState
    extends State<_CancelShippingOperationListBody> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _gincFilterController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedStatus;
  String _sortBy = 'processedAt';
  String _sortDir = 'desc';
  bool _initialLoadDone = false;
  bool _bindRefreshDone = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onFiltersChanged);
    _gincFilterController.addListener(_onFiltersChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bindRefreshDone) {
      _bindRefreshDone = true;
      widget.onBindRefresh?.call(
        () => context.read<OperationsCubit<Operation>>().refresh(),
      );
    }
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      return;
    }
    if (!widget.embedded) {
      context.read<OperationsCubit<Operation>>().refresh();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _gincFilterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFiltersChanged() => setState(() {});

  void _filterOperations() => setState(() {});

  List<Operation> _filteredOperations(List<Operation> operations) {
    return CancelShippingOperationListFilter.applyToOperations(
      operations: operations,
      query: _searchController.text,
      statusFilter: _selectedStatus,
      gincFilter: _gincFilterController.text,
      sortBy: _sortBy,
      sortDir: _sortDir,
    );
  }

  void _syncEmbeddedOperationIds(List<Operation> filtered) {
    if (!widget.embedded) return;
    final ids = filtered
        .map((op) => op.navigableOperationId)
        .whereType<String>()
        .toList();
    context
        .read<OperationSplitCubit>()
        .updateOperationIds(ids, isEmpty: ids.isEmpty);
  }

  void _showFilterDialog() {
    CancelShippingQuickFilterDialog.open(
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
        title: const Text(CancelShippingUiConstants.advancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return CancelShippingAdvancedFiltersPanel(
                gincController: _gincFilterController,
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

  String _sortFieldDisplayLabel() {
    return CancelShippingUiConstants.sortFieldLabels[_sortBy] ??
        CancelShippingUiConstants.sortFieldFallback;
  }

  void _clearAllFilters() {
    _searchController.clear();
    _gincFilterController.clear();
    setState(() {
      _selectedStatus = null;
      _sortBy = 'processedAt';
      _sortDir = 'desc';
    });
    _filterOperations();
  }

  void _navigateToDetail(Operation operation) {
    final id = operation.navigableOperationId;
    if (id == null) return;
    if (widget.embedded && widget.onSelectOperation != null) {
      widget.onSelectOperation!(id);
    } else {
      context.go('${Constants.opCancelShippingRoute}/$id');
    }
  }

  bool get _hasActiveAdvancedFilters =>
      _gincFilterController.text.isNotEmpty ||
      _sortBy != 'processedAt' ||
      _sortDir != 'desc';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationsCubit<Operation>, OperationsState<Operation>>(
      listener: (context, state) {
        widget.onLoadingChanged?.call(state.isLoading);

        final filtered = _filteredOperations(state.items);
        _syncEmbeddedOperationIds(filtered);

        if (widget.embedded &&
            widget.selectedOperationId == null &&
            !state.isLoading &&
            state.errorMessage == null &&
            filtered.isNotEmpty) {
          final firstId = filtered.first.navigableOperationId;
          if (firstId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onSelectOperation?.call(firstId);
            });
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
                        _gincFilterController,
                      ]),
                      builder: (context, _) {
                        return Gs1ListSearchBar(
                          hintText: CancelShippingUiConstants.listSearchHint,
                          controller: _searchController,
                          showAdvancedFilters: _hasActiveAdvancedFilters ||
                              _selectedStatus != null,
                          onSearch: _filterOperations,
                          onQueryChanged: (_) => _filterOperations(),
                          onRefresh: cubit.refresh,
                          onQuickFilters: _showFilterDialog,
                          onToggleAdvancedFilters: _showAdvancedFiltersDialog,
                          onClear: () {
                            _searchController.clear();
                            _filterOperations();
                          },
                          sortTooltip: CancelShippingUiConstants.sortByLine(
                            _sortFieldDisplayLabel(),
                            _sortDir == 'asc'
                                ? CancelShippingUiConstants.sortAscendingLabel
                                : CancelShippingUiConstants.sortDescendingLabel,
                          ),
                          sortOrder: _sortDir,
                          onSortOrderChanged: (order) {
                            if (_sortDir != order) {
                              setState(() => _sortDir = order);
                              _filterOperations();
                            }
                          },
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
            hasActiveFilters:
                _selectedStatus != null || _hasActiveAdvancedFilters,
            onRetry: cubit.refresh,
            onRefresh: cubit.refresh,
            onClearFilters: _clearAllFilters,
            emptyTitle: 'No cancel shipping operations yet',
            emptySubtitle:
                'Tap the + button to create your first cancel shipping operation.',
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            onLoadMore: cubit.loadMore,
            itemBuilder: (context, operation) =>
                OperationListCardBuilders.forOperation(
              operation: operation,
              isSelected: widget.embedded &&
                  operation.navigableOperationId != null &&
                  operation.navigableOperationId ==
                      widget.selectedOperationId,
              onTap: () => _navigateToDetail(operation),
            ),
          ),
        );

        if (widget.embedded) return body;

        return Scaffold(
          appBar: TraqAppBar(
            context,
            title: const Text('Cancel Shipping'),
          ),
          drawer: const AppDrawer(),
          floatingActionButton: widget.onEmbeddedCreate != null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () =>
                      context.go(Constants.opCancelShippingCreateRoute),
                  label: TraqIcon(AppAssets.iconPlus),
                ),
          body: body,
        );
      },
    );
  }
}
