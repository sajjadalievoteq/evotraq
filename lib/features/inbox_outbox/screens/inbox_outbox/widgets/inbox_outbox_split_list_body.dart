import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/data/models/inbox_outbox/inbox_outbox_list_filter.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_mapper.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/services/inbox_outbox/inbox_outbox_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/inbox_outbox/screens/inbox_outbox/widgets/inbox_outbox_results.dart';
import 'package:traqtrace_app/features/inbox_outbox/screens/inbox_outbox/widgets/inbox_outbox_toolbar.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';

class InboxOutboxSplitListBody extends StatefulWidget {
  const InboxOutboxSplitListBody({
    super.key,
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
  State<InboxOutboxSplitListBody> createState() => _InboxOutboxSplitListBodyState();
}

class _InboxOutboxSplitListBodyState extends State<InboxOutboxSplitListBody> {
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
        final pageResult = await getIt<InboxOutboxService>().getFilteredInTransitPage(
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
          final ids = state.items.map((op) => op.navigableOperationId).whereType<String>().toList();
          context.read<OperationSplitCubit>().updateOperationIds(ids, isEmpty: ids.isEmpty);
          context.read<OperationSplitCubit>().setListLoading(state.isLoading);
        },
        builder: (context, state) {
          final body = Gs1MasterListBody(
            toolbar: InboxOutboxToolbar(
              searchController: _searchController,
              showFilterChips: _showFilterChips,
              selectedFilter: _listFilter,
              onRefresh: _cubit.refresh,
              onQueryChanged: (_) => _cubit.refresh(),
              onClear: () {
                _searchController.clear();
                _cubit.refresh();
              },
              onFilterSelected: _onFilterSelected,
            ),
            results: InboxOutboxResults(
              scrollController: _scrollController,
              operations: state.items,
              isLoading: state.isLoading,
              errorMessage: state.errorMessage,
              filter: _listFilter,
              onRetry: _cubit.refresh,
              onRefresh: _cubit.refresh,
              onClearFilters: () => _onFilterSelected(InboxOutboxListFilter.all),
              emptyIconAsset: widget.emptyIconAsset ?? NavIcons.inboxOutbox,
              hasMore: state.hasMore,
              isLoadingMore: state.isLoadingMore,
              onLoadMore: _cubit.loadMore,
              embedded: widget.embedded,
              selectedOperationId: widget.selectedOperationId,
              onSelectOperation: widget.onSelectOperation,
            ),
          );

          if (widget.embedded) return body;
          return Scaffold(body: body);
        },
      ),
    );
  }
}
