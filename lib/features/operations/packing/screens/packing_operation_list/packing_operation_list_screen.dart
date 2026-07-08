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
import 'package:traqtrace_app/data/services/operations/packing/packing_operation_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/utils/packing_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/widgets/packing_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/widgets/packing_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card_builders.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_results.dart';

class PackingOperationListScreen extends StatelessWidget {
  const PackingOperationListScreen({
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperationsCubit<Operation>(
        loadErrorMessage:
            'Could not load packing operations. Check your connection and tap Retry.',
        loadMoreErrorMessage:
            'Could not load more operations. Check your connection and try again.',
        fetchList: ({required int page, required int size}) async {
          final pageResult = await getIt<PackingOperationService>()
              .getPackingOperationsPage(page: page, size: size);
          return pageResult.map((r) => r.toOperation());
        },
      )..loadInitial(),
      child: _PackingOperationListBody(
        embedded: embedded,
        onSelectOperation: onSelectOperation,
        selectedOperationId: selectedOperationId,
        onLoadingChanged: onLoadingChanged,
      ),
    );
  }
}

class _PackingOperationListBody extends StatefulWidget {
  const _PackingOperationListBody({
    required this.embedded,
    this.onSelectOperation,
    this.selectedOperationId,
    this.onLoadingChanged,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedOperationId;
  final ValueChanged<bool>? onLoadingChanged;

  @override
  State<_PackingOperationListBody> createState() =>
      _PackingOperationListBodyState();
}

class _PackingOperationListBodyState extends State<_PackingOperationListBody> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _containerFilterController =
      TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedStatus;
  String _sortBy = 'processedAt';
  String _sortDir = 'desc';
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onFiltersChanged);
    _containerFilterController.addListener(_onFiltersChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    _containerFilterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFiltersChanged() => setState(() {});

  void _filterOperations() => setState(() {});

  List<Operation> _filteredOperations(List<Operation> operations) {
    return PackingOperationListFilter.applyToOperations(
      operations: operations,
      query: _searchController.text,
      statusFilter: _selectedStatus,
      containerFilter: _containerFilterController.text,
      sortBy: _sortBy,
      sortDir: _sortDir,
    );
  }

  void _showFilterDialog() {
    PackingQuickFilterDialog.open(
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
        title: const Text(PackingUiConstants.advancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return PackingAdvancedFiltersPanel(
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

  String _sortFieldDisplayLabel() {
    return PackingUiConstants.sortFieldLabels[_sortBy] ??
        PackingUiConstants.sortFieldFallback;
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

  void _navigateToDetail(Operation operation) {
    final id = operation.navigableOperationId;
    if (id == null) return;
    if (widget.embedded && widget.onSelectOperation != null) {
      widget.onSelectOperation!(id);
    } else {
      context.go('${Constants.opPackingRoute}/$id');
    }
  }

  bool get _hasActiveAdvancedFilters =>
      _containerFilterController.text.isNotEmpty ||
      _sortBy != 'processedAt' ||
      _sortDir != 'desc';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OperationsCubit<Operation>, OperationsState<Operation>>(
      listener: (context, state) {
        widget.onLoadingChanged?.call(state.isLoading);

        if (widget.embedded &&
            widget.selectedOperationId == null &&
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
                        _containerFilterController,
                      ]),
                      builder: (context, _) {
                        return Gs1ListSearchBar(
                          hintText: PackingUiConstants.listSearchHint,
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
                          sortTooltip: PackingUiConstants.sortByLine(
                            _sortFieldDisplayLabel(),
                            _sortDir == 'asc'
                                ? PackingUiConstants.sortAscendingLabel
                                : PackingUiConstants.sortDescendingLabel,
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
            emptyTitle: 'No packing operations yet',
            emptySubtitle:
                'Tap the + button to create your first packing operation.',
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
            title: const Text('Packing Operation'),
          ),
          drawer: const AppDrawer(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go(Constants.opPackingCreateRoute),
            label: TraqIcon(AppAssets.iconPlus),
          ),
          body: body,
        );
      },
    );
  }
}
