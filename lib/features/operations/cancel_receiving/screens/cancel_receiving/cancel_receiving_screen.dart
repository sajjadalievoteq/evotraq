import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/cubit/cancel_receiving_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/cancel_receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_list/cancel_receiving_operation_list_screen.dart';

class CancelReceivingScreen extends StatefulWidget {
  const CancelReceivingScreen({super.key});

  @override
  State<CancelReceivingScreen> createState() => _CancelReceivingScreenState();
}

class _CancelReceivingScreenState extends State<CancelReceivingScreen> {
  late final CancelReceivingOperationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CancelReceivingOperationsCubit();
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
        split: Gs1SplitViewScreen<CancelReceivingOperationsCubit, CancelReceivingOperationsState>(
          appBarTitle: 'Cancel Receiving',
          fabHeroTag: 'cancel_receiving_fab',
          fabAddTooltip: 'New Cancellation',
          fabCloseTooltip: 'Close create panel',
          createHeaderText: 'New Cancel Receiving',
          closeCreateTooltip: 'Close',
          emptyNoMatchText: 'No Cancel Receiving match your search.',
          fabNavigateRoute: Constants.opCancelReceivingCreateRoute,
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
              CancelReceivingOperationListScreen(
                embedded: true,
                selectedOperationId: selectedId,
                onSelectOperation: onSelect,
                onBindRefresh: bindRefresh,
                onEmbeddedCreate: onRequestCreate,
              ),
          detailViewBuilder: (context, id) => CancelReceivingOperationDetailScreen(
            key: ValueKey(id),
            operationId: id,
            embedded: true,
          ),
          detailAwaitBuilder: (context) => const CancelReceivingOperationDetailScreen(
            key: ValueKey('__cancel_receiving_split_await__'),
            embedded: true,
            awaitingSelection: true,
          ),
        ),
        fallback: const CancelReceivingOperationListScreen(),
      ),
    );
  }
}
