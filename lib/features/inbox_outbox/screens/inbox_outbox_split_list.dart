import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_mapper.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/services/operations/inbox_outbox/inbox_outbox_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/inbox_outbox/models/inbox_outbox_list_filter.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_results.dart';

class InboxOutboxSplitList extends StatelessWidget {
  const InboxOutboxSplitList({
    super.key,
    this.embedded = false,
    this.onSelectOperation,
    this.selectedOperationId,
    this.onBindRefresh,
    this.emptyIconAsset,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedOperationId;
  final void Function(VoidCallback refreshFn)? onBindRefresh;
  final String? emptyIconAsset;

  @override
  Widget build(BuildContext context) {
    return _InboxOutboxSplitListBody(
      embedded: embedded,
      onSelectOperation: onSelectOperation,
      selectedOperationId: selectedOperationId,
      onBindRefresh: onBindRefresh,
      emptyIconAsset: emptyIconAsset,
    );
  }
}

class _InboxOutboxSplitListBody extends StatefulWidget {
  const _InboxOutboxSplitListBody({
    required this.embedded,
    this.onSelectOperation,
    this.selectedOperationId,
    this.onBindRefresh,
    this.emptyIconAsset,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedOperationId;
  final void Function(VoidCallback refreshFn)? onBindRefresh;
  final String? emptyIconAsset;

  @override
  State<_InboxOutboxSplitListBody> createState() =>
      _InboxOutboxSplitListBodyState();
}

class _InboxOutboxSplitListBodyState extends State<_InboxOutboxSplitListBody> {
  final TextEditingController _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _bindRefreshDone = false;
  bool _loadingGln = true;
  bool _showFilterChips = true;
  String? _myGln;
  InboxOutboxListFilter _listFilter = InboxOutboxListFilter.all;
  late final OperationsCubit<Operation> _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = OperationsCubit<Operation>(
      loadErrorMessage:
          'Could not load in-transit shipments. Check your connection and tap Retry.',
      loadMoreErrorMessage:
          'Could not load more shipments. Check your connection and try again.',
      fetchList: ({required page, required size}) async {
        final gln = _myGln;
        if (gln == null) {
          return const OperationPage<Operation>(
            operations: [],
            page: 0,
            size: 20,
            count: 0,
            total: 0,
            totalPages: 0,
          );
        }
        final pageResult =
            await getIt<InboxOutboxService>().getFilteredInTransitPage(
          gln: gln,
          filter: _listFilter,
          page: page,
          size: size,
          search: _searchController.text,
        );
        return pageResult.map((r) => r.toOperation());
      },
    );
    _loadOperationalGln();
  }

  Future<void> _loadOperationalGln() async {
    final userId = context.read<AuthCubit>().state.user?.id;
    if (userId == null) {
      if (mounted) setState(() => _loadingGln = false);
      return;
    }
    final stored = await OperationalGlnStore.getGln(userId);
    if (!mounted) return;
    setState(() {
      _loadingGln = false;
      _myGln = stored;
    });
    if (stored != null) {
      await _cubit.loadInitial();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bindRefreshDone) {
      _bindRefreshDone = true;
      widget.onBindRefresh?.call(() => _cubit.refresh());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onFilterSelected(InboxOutboxListFilter filter) {
    if (_listFilter == filter) return;
    setState(() => _listFilter = filter);
    _cubit.refresh();
  }

  String get _emptyTitle {
    return switch (_listFilter) {
      InboxOutboxListFilter.all => 'No in-transit shipments',
      InboxOutboxListFilter.inbox => 'No inbound shipments in transit',
      InboxOutboxListFilter.outbox => 'No outbound shipments in transit',
    };
  }

  String get _emptySubtitle {
    return switch (_listFilter) {
      InboxOutboxListFilter.all =>
        'Open shipments to or from your operational location appear here.',
      InboxOutboxListFilter.inbox =>
        'Shipments addressed to your location appear here until received.',
      InboxOutboxListFilter.outbox =>
        'Shipments you sent appear here until the destination receives them.',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingGln) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myGln == null) {
      return AppEmptyState(
        iconAsset: NavIcons.inboxOutbox,
        title: 'Operational GLN not set',
        subtitle:
            'Set your operational location in Profile to load in-transit shipments for your site.',
        primaryActionLabel: 'Open Profile',
        primaryActionIconAsset: NavIcons.profile,
        onPrimaryAction: () => context.go(Constants.profileRoute),
      );
    }

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<OperationsCubit<Operation>, OperationsState<Operation>>(
        listener: (context, state) {
          if (!widget.embedded) return;
          final ids = state.items
              .map((op) => op.navigableOperationId)
              .whereType<String>()
              .toList();
          context
              .read<OperationSplitCubit>()
              .updateOperationIds(ids, isEmpty: ids.isEmpty);
          context.read<OperationSplitCubit>().setListLoading(state.isLoading);
        },
        builder: (context, state) {
          final body = Gs1MasterListBody(
            toolbar: Padding(
              padding: EdgeInsets.fromLTRB(context.padding.top, context.padding.top,context.padding.top, 0),
              child: Column(
                children: [
                  Gs1ListSearchBar(
                    hintText: 'Search in-transit shipments',
                    controller: _searchController,
                    showAdvancedFilters: _showFilterChips,
                    showAdvancedFilterIcon: false,
                    onSearch: _cubit.refresh,
                    onQueryChanged: (_) => _cubit.refresh(),
                    onRefresh: _cubit.refresh,
                    onToggleAdvancedFilters: () {

                    },
                    onClear: () {
                      _searchController.clear();
                      _cubit.refresh();
                    },
                  ),
                  if (_showFilterChips) ...[
                    const SizedBox(height: 12),
                    _InboxOutboxFilterChips(
                      selected: _listFilter,
                      onSelected: _onFilterSelected,
                    ),
                  ],
                ],
              ),
            ),
            results: OperationListResults<Operation>(
              scrollController: _scrollController,
              isLoading: state.isLoading,
              errorMessage: state.errorMessage,
              operations: state.items,
              filteredOperations: state.items,
              hasActiveFilters: _listFilter != InboxOutboxListFilter.all,
              onRetry: _cubit.refresh,
              onRefresh: _cubit.refresh,
              onClearFilters: () => _onFilterSelected(InboxOutboxListFilter.all),
              emptyTitle: _emptyTitle,
              emptySubtitle: _emptySubtitle,
              emptyIconAsset: widget.emptyIconAsset ?? NavIcons.inboxOutbox,
              hasMore: state.hasMore,
              isLoadingMore: state.isLoadingMore,
              onLoadMore: _cubit.loadMore,
              itemBuilder: (context, operation) => OperationListCard(
                operation: operation,
                isSelected: widget.embedded &&
                    operation.navigableOperationId != null &&
                    operation.navigableOperationId ==
                        widget.selectedOperationId,
                onTap: () {
                  final id = operation.navigableOperationId;
                  if (id == null) return;
                  if (widget.embedded && widget.onSelectOperation != null) {
                    widget.onSelectOperation!(id);
                  } else {
                    context.go('${Constants.opShippingRoute}/$id');
                  }
                },
              ),
            ),
          );

          if (widget.embedded) return body;
          return Scaffold(body: body);
        },
      ),
    );
  }
}

class _InboxOutboxFilterChips extends StatelessWidget {
  const _InboxOutboxFilterChips({
    required this.selected,
    required this.onSelected,
  });

  final InboxOutboxListFilter selected;
  final ValueChanged<InboxOutboxListFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: InboxOutboxListFilter.values.map((filter) {
          return FilterChip(
            selectedColor: context.colors.primary,
            label: Text(filter.label),
            selected: selected == filter,
            onSelected: (_) => onSelected(filter),
          );
        }).toList(),
      ),
    );
  }
}
