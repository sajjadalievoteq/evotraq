import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/utils/auth_role_context.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_list_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/utils/commissioning_operation_list_filter.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_state.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_results.dart';

class CommissioningOperationListBody extends StatefulWidget {
  const CommissioningOperationListBody({
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
    this.onBindRefresh,
    this.onEmbeddedCreate,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedBatchId;
  final ValueChanged<bool>? onLoadingChanged;
  final void Function(VoidCallback refreshFn)? onBindRefresh;
  final VoidCallback? onEmbeddedCreate;
  final TextEditingController gtinFilterController;
  final String sortBy;
  final String sortDir;
  final int pageSize;
  final void Function({String? sortBy, String? sortDir}) onServerSortChanged;
  final ValueChanged<int> onPageSizeChanged;
  final VoidCallback onServerReload;

  @override
  State<CommissioningOperationListBody> createState() =>
      CommissioningOperationListBodyState();
}

class CommissioningOperationListBodyState
    extends State<CommissioningOperationListBody> {
  final TextEditingController _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedStatus;
  bool _bindRefreshDone = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onFiltersChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bindRefreshDone) {
      _bindRefreshDone = true;
      widget.onBindRefresh?.call(widget.onServerReload);
    }
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

  void _syncEmbeddedOperationIds(List<Operation> filtered) {
    if (!widget.embedded) return;
    final ids = filtered
        .map((op) => op.navigableOperationId)
        .whereType<String>()
        .toList();
    context.read<OperationSplitCubit>().updateOperationIds(
      ids,
      isEmpty: ids.isEmpty,
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
      context.push('${Constants.opCommissioningRoute}/$id');
    }
  }

  bool get _hasActiveFilters =>
      _selectedStatus != null ||
      widget.gtinFilterController.text.isNotEmpty ||
      widget.sortBy != 'createdAt' ||
      widget.sortDir != 'desc';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      CommissioningOperationListCubit,
      OperationsState<Operation>
    >(
      buildWhen: (previous, current) =>
          previous.items != current.items ||
          previous.isLoading != current.isLoading ||
          previous.isLoadingMore != current.isLoadingMore ||
          previous.hasMore != current.hasMore ||
          previous.errorMessage != current.errorMessage ||
          previous.total != current.total,
      listener: (context, state) {
        widget.onLoadingChanged?.call(state.isLoading);
        final filtered = _filteredOperations(state.items);
        if (widget.embedded) {
          final split = context.read<OperationSplitCubit>();
          if (state.isLoading) {
            split.setListLoading(true);
          } else {
            _syncEmbeddedOperationIds(filtered);
            split.setListLoading(false);
          }
        }
      },
      builder: (context, state) {
        final filtered = _filteredOperations(state.items);
        final cubit = context.read<CommissioningOperationListCubit>();

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
            emptyIconAsset: NavIcons.commissioning,
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            onLoadMore: cubit.loadMore,
            itemBuilder: (context, operation) => OperationListCard(
              operation: operation,
              isSelected:
                  widget.embedded &&
                  operation.navigableOperationId != null &&
                  operation.navigableOperationId == widget.selectedBatchId,
              onTap: () => _navigateToDetail(operation),
            ),
          ),
        );

        if (widget.embedded) return body;

        return Scaffold(
          appBar: TraqAppBar(context, title: const Text('Commissioning')),
          drawer: const AppDrawer(),
          floatingActionButton: !context.canPerform(OperationSteps.commission)
              ? null
              : FloatingActionButton.extended(
                  onPressed: () =>
                      context.push(Constants.opCommissioningNewRoute),
                  icon: TraqIcon(AppAssets.iconPlus),
                  label: const Text('New Commissioning'),
                ),
          body: body,
        );
      },
    );
  }
}
