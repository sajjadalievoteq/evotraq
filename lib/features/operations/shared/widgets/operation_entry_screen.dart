import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';

/// Generic entry screen for operations that use the Gs1SplitViewScreen split
/// view pattern.
class OperationEntryScreen extends StatefulWidget {
  const OperationEntryScreen({
    super.key,
    required this.appBarTitle,
    required this.fabHeroTag,
    required this.fabAddTooltip,
    required this.fabNavigateRoute,
    required this.createHeaderText,
    required this.emptyNoMatchText,
    required this.listBuilder,
    required this.detailViewBuilder,
    required this.detailAwaitBuilder,
    this.fallbackList,
  });

  final String appBarTitle;
  final String fabHeroTag;
  final String fabAddTooltip;
  final String fabNavigateRoute;
  final String createHeaderText;
  final String emptyNoMatchText;

  final Widget Function(
    BuildContext context, {
    required String? selectedId,
    required ValueChanged<String> onSelect,
    required void Function(VoidCallback refresh) bindRefresh,
    required VoidCallback onRequestCreate,
  }) listBuilder;

  final Widget Function(BuildContext context, String id) detailViewBuilder;
  final Widget Function(BuildContext context) detailAwaitBuilder;
  final Widget? fallbackList;

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
          fabHeroTag: widget.fabHeroTag,
          fabAddTooltip: widget.fabAddTooltip,
          fabCloseTooltip: 'Close create panel',
          createHeaderText: widget.createHeaderText,
          closeCreateTooltip: 'Close',
          emptyNoMatchText: widget.emptyNoMatchText,
          fabNavigateRoute: widget.fabNavigateRoute,
          listenWhenListChanged: (prev, curr) =>
              prev.operationIds != curr.operationIds,
          idsFromState: (s) => s.operationIds,
          createdIdFromState: (s) => s.createdOperationId,
          isEmptyNoMatch: (s) => s.isEmpty,
          listBuilder: widget.listBuilder,
          detailViewBuilder: widget.detailViewBuilder,
          detailAwaitBuilder: widget.detailAwaitBuilder,
        ),
        fallback: widget.fallbackList ??
            widget.listBuilder(
              context,
              selectedId: null,
              onSelect: (_) {},
              bindRefresh: (_) {},
              onRequestCreate: () {},
            ),
      ),
    );
  }
}
