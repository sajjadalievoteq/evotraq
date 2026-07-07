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
import 'package:traqtrace_app/data/services/operations/receiving/receiving_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_list/utils/receiving_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_list/widgets/receiving_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_list/widgets/receiving_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/receiving/utils/receiving_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card_builders.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_results.dart';

/// Screen to list all Receiving operations with search capabilities.
class ReceivingOperationListScreen extends StatelessWidget {
  const ReceivingOperationListScreen({
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
            'Could not load Receiving operations. Check your connection and tap Retry.',
        loadMoreErrorMessage:
            'Could not load more operations. Check your connection and try again.',
        fetchList: ({required int page, required int size}) async {
          final pageResult = await getIt<ReceivingOperationService>()
              .getReceivingOperationsPage(page: page, size: size);
          return pageResult.map((r) => r.toOperation());
        },
      )..loadInitial(),
      child: _ReceivingOperationListBody(
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

class _ReceivingOperationListBody extends StatefulWidget {
  const _ReceivingOperationListBody({
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
  State<_ReceivingOperationListBody> createState() =>
      _ReceivingOperationListBodyState();
}

class _ReceivingOperationListBodyState
    extends State<_ReceivingOperationListBody> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _trackingFilterController =
      TextEditingController();
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
    _trackingFilterController.addListener(_onFiltersChanged);
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
    _trackingFilterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFiltersChanged() => setState(() {});

  void _filterOperations() => setState(() {});

  List<Operation> _filteredOperations(List<Operation> operations) {
    return ReceivingOperationListFilter.applyToOperations(
      operations: operations,
      query: _searchController.text,
      statusFilter: _selectedStatus,
      trackingFilter: _trackingFilterController.text,
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
    ReceivingQuickFilterDialog.open(
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
        title: const Text(ReceivingUiConstants.advancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return ReceivingAdvancedFiltersPanel(
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

  String _sortFieldDisplayLabel() {
    return ReceivingUiConstants.sortFieldLabels[_sortBy] ??
        ReceivingUiConstants.sortFieldFallback;
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

  void _navigateToDetail(Operation operation) {
    final id = operation.navigableOperationId;
    if (id == null) return;
    if (widget.embedded && widget.onSelectOperation != null) {
      widget.onSelectOperation!(id);
    } else {
      context.go('${Constants.opReceivingRoute}/$id');
    }
  }

  bool get _hasActiveAdvancedFilters =>
      _trackingFilterController.text.isNotEmpty ||
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
                        _trackingFilterController,
                      ]),
                      builder: (context, _) {
                        return Gs1ListSearchBar(
                          hintText: ReceivingUiConstants.listSearchHint,
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
                          sortTooltip: ReceivingUiConstants.sortByLine(
                            _sortFieldDisplayLabel(),
                            _sortDir == 'asc'
                                ? ReceivingUiConstants.sortAscendingLabel
                                : ReceivingUiConstants.sortDescendingLabel,
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
            emptyTitle: 'No Receiving operations yet',
            emptySubtitle:
                'Tap the + button to create your first Receiving operation.',
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
            title: const Text('Receiving Operation'),
          ),
          drawer: const AppDrawer(),
          floatingActionButton: widget.onEmbeddedCreate != null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => context.go(Constants.opReceivingCreateRoute),
                  label: TraqIcon(AppAssets.iconPlus),
                ),
          body: body,
        );
      },
    );
  }
}
