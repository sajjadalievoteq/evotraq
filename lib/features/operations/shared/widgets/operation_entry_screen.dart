import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_route.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_state.dart';

class OperationEntryScreen extends StatefulWidget {
  const OperationEntryScreen({
    super.key,
    required this.appBarTitle,
    required this.listRoute,
    required this.detailRoute,
    required this.fabHeroTag,
    required this.fabAddTooltip,
    required this.fabNavigateRoute,
    required this.createHeaderText,
    required this.emptyNoMatchText,
    required this.listBuilder,
    required this.detailViewBuilder,
    required this.detailAwaitBuilder,
    this.fallbackList,
    this.showFloatingActionButton = true,
  });

  final String appBarTitle;
  final String listRoute;
  final String Function(String id) detailRoute;
  final String fabHeroTag;
  final String fabAddTooltip;
  final String fabNavigateRoute;
  final String createHeaderText;
  final String emptyNoMatchText;

  final Widget Function(
    BuildContext context, {
    required String? selectedId,
    required MasterDetailSelectCallback onSelect,
    required void Function(VoidCallback refresh) bindRefresh,
    required VoidCallback onRequestCreate,
  })
  listBuilder;

  final Widget Function(BuildContext context, String id, {required bool editing})
  detailViewBuilder;
  final Widget Function(BuildContext context, {required bool listLoading})
  detailAwaitBuilder;
  final Widget? fallbackList;
  final bool showFloatingActionButton;

  @override
  State<OperationEntryScreen> createState() => _OperationEntryScreenState();
}

class _OperationEntryScreenState extends State<OperationEntryScreen> {
  late final OperationSplitCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = OperationSplitCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: SplitOrListIndexedStack(
        split: Gs1SplitViewScreen<OperationSplitCubit, OperationSplitState>(
          appBarTitle: widget.appBarTitle,
          listRoute: widget.listRoute,
          fabHeroTag: widget.fabHeroTag,
          fabAddTooltip: widget.fabAddTooltip,
          fabCloseTooltip: 'Close create panel',
          createHeaderText: widget.createHeaderText,
          closeCreateTooltip: 'Close',
          emptyNoMatchText: widget.emptyNoMatchText,
          fabNavigateRoute: widget.fabNavigateRoute,
          listenWhenListChanged: (prev, curr) =>
              prev.operationIds != curr.operationIds ||
              prev.isListLoading != curr.isListLoading,
          idsFromState: (s) => s.operationIds,
          createdIdFromState: (s) => s.createdOperationId,
          isEmptyNoMatch: (s) => s.isEmpty,
          isListLoading: (s) => s.isListLoading,
          listBuilder: widget.listBuilder,
          detailViewBuilder: widget.detailViewBuilder,
          detailAwaitBuilder: widget.detailAwaitBuilder,
          showFloatingActionButton: widget.showFloatingActionButton,
        ),
        fallback: MasterDetailMobileRedirect(
          listRoute: widget.listRoute,
          detailRoute: widget.detailRoute,
          child:
              widget.fallbackList ??
              widget.listBuilder(
                context,
                selectedId: null,
                onSelect: (_, {editing = false}) {},
                bindRefresh: (_) {},
                onRequestCreate: () {},
              ),
        ),
      ),
    );
  }
}
