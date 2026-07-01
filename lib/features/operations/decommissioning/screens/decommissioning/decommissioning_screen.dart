import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/decommissioning/cubit/decommissioning_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/decommissioning_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_list/decommissioning_operation_list_screen.dart';

class DecommissioningScreen extends StatefulWidget {
  const DecommissioningScreen({super.key});

  @override
  State<DecommissioningScreen> createState() => _DecommissioningScreenState();
}

class _DecommissioningScreenState extends State<DecommissioningScreen> {
  late final DecommissioningOperationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DecommissioningOperationsCubit();
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
        split: Gs1SplitViewScreen<DecommissioningOperationsCubit,
            DecommissioningOperationsState>(
          appBarTitle: 'Decommissioning Operations',
          fabHeroTag: 'decommissioning_fab',
          fabAddTooltip: 'New decommissioning operation',
          fabCloseTooltip: 'Close create panel',
          createHeaderText: 'New Decommissioning Operation',
          closeCreateTooltip: 'Close',
          emptyNoMatchText:
              'No decommissioning operations match your search.',
          fabNavigateRoute: Constants.opDecommissioningCreateRoute,
          listenWhenListChanged: (prev, curr) =>
              prev.operationIds != curr.operationIds,
          idsFromState: (s) => s.operationIds,
          createdIdFromState: (s) => s.createdOperationId,
          isEmptyNoMatch: (s) => s.isEmpty,
          listBuilder: (context, {
            required selectedId,
            required onSelect,
            required bindRefresh,
            required onRequestCreate,
          }) =>
              DecommissioningOperationListScreen(
                embedded: true,
                selectedOperationId: selectedId,
                onSelectOperation: onSelect,
                onBindRefresh: bindRefresh,
                onEmbeddedCreate: onRequestCreate,
              ),
          detailViewBuilder: (context, id) =>
              DecommissioningOperationDetailScreen(
            key: ValueKey(id),
            operationId: id,
            embedded: true,
          ),
          detailAwaitBuilder: (context) =>
              const DecommissioningOperationDetailScreen(
            key: ValueKey('__decommissioning_split_await__'),
            embedded: true,
            awaitingSelection: true,
          ),
        ),
        fallback: const DecommissioningOperationListScreen(),
      ),
    );
  }
}
