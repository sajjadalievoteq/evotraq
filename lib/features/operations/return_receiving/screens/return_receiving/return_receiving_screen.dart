import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/return_receiving/cubit/return_receiving_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/return_receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_list/return_receiving_operation_list_screen.dart';

class ReturnReceivingScreen extends StatefulWidget {
  const ReturnReceivingScreen({super.key});

  @override
  State<ReturnReceivingScreen> createState() => _ReturnReceivingScreenState();
}

class _ReturnReceivingScreenState extends State<ReturnReceivingScreen> {
  late final ReturnReceivingOperationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ReturnReceivingOperationsCubit();
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
        split:
            Gs1SplitViewScreen<
              ReturnReceivingOperationsCubit,
              ReturnReceivingOperationsState
            >(
              appBarTitle: 'Return Receiving',
              fabHeroTag: 'return_receiving_fab',
              fabAddTooltip: 'New return receiving',
              fabCloseTooltip: 'Close create panel',
              createHeaderText: 'New Return Receiving',
              closeCreateTooltip: 'Close',
              emptyNoMatchText:
                  'No return receiving match your search.',
              fabNavigateRoute: Constants.opReturnReceivingCreateRoute,
              listenWhenListChanged: (prev, curr) =>
                  prev.operationIds != curr.operationIds,
              idsFromState: (s) => s.operationIds,
              createdIdFromState: (s) => s.createdOperationId,
              isEmptyNoMatch: (s) => s.isEmpty,
              listBuilder:
                  (
                    context, {
                    required selectedId,
                    required onSelect,
                    required bindRefresh,
                    required onRequestCreate,
                  }) => ReturnReceivingOperationListScreen(
                    embedded: true,
                    selectedOperationId: selectedId,
                    onSelectOperation: onSelect,
                    onBindRefresh: bindRefresh,
                    onEmbeddedCreate: onRequestCreate,
                  ),
              detailViewBuilder: (context, id) =>
                  ReturnReceivingOperationDetailScreen(
                    key: ValueKey(id),
                    operationId: id,
                    embedded: true,
                  ),
              detailAwaitBuilder: (context) =>
                  const ReturnReceivingOperationDetailScreen(
                    key: ValueKey('__return_receiving_split_await__'),
                    embedded: true,
                    awaitingSelection: true,
                  ),
            ),
        fallback: const ReturnReceivingOperationListScreen(),
      ),
    );
  }
}
