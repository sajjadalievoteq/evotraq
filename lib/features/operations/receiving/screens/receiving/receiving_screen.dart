import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/receiving/cubit/receiving_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_list/receiving_operation_list_screen.dart';

class ReceivingScreen extends StatefulWidget {
  const ReceivingScreen({super.key});

  @override
  State<ReceivingScreen> createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
  late final ReceivingOperationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ReceivingOperationsCubit();
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
        split: Gs1SplitViewScreen<ReceivingOperationsCubit, ReceivingOperationsState>(
          appBarTitle: 'Receiving Operations',
          fabHeroTag: 'receiving_fab',
          fabAddTooltip: 'New Receiving operation',
          fabCloseTooltip: 'Close create panel',
          createHeaderText: 'New Receiving Operation',
          closeCreateTooltip: 'Close',
          emptyNoMatchText: 'No Receiving operations match your search.',
          fabNavigateRoute: Constants.opReceivingCreateRoute,
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
              ReceivingOperationListScreen(
                embedded: true,
                selectedOperationId: selectedId,
                onSelectOperation: onSelect,
                onBindRefresh: bindRefresh,
                onEmbeddedCreate: onRequestCreate,
              ),
          detailViewBuilder: (context, id) => ReceivingOperationDetailScreen(
            key: ValueKey(id),
            operationId: id,
            embedded: true,
          ),
          detailAwaitBuilder: (context) => const ReceivingOperationDetailScreen(
            key: ValueKey('__receiving_split_await__'),
            embedded: true,
            awaitingSelection: true,
          ),
        ),
        fallback: const ReceivingOperationListScreen(),
      ),
    );
  }
}
