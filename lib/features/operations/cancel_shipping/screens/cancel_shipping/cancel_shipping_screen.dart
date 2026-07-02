import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/cubit/cancel_shipping_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/cancel_shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_list/cancel_shipping_operation_list_screen.dart';

class CancelShippingScreen extends StatefulWidget {
  const CancelShippingScreen({super.key});

  @override
  State<CancelShippingScreen> createState() => _CancelShippingScreenState();
}

class _CancelShippingScreenState extends State<CancelShippingScreen> {
  late final CancelShippingOperationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CancelShippingOperationsCubit();
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
        split: Gs1SplitViewScreen<CancelShippingOperationsCubit, CancelShippingOperationsState>(
          appBarTitle: 'Cancel Shipping',
          fabHeroTag: 'cancel_shipping_fab',
          fabAddTooltip: 'New Cancellation',
          fabCloseTooltip: 'Close create panel',
          createHeaderText: 'New Cancel Shipping',
          closeCreateTooltip: 'Close',
          emptyNoMatchText: 'No Cancel Shipping match your search.',
          fabNavigateRoute: Constants.opCancelShippingCreateRoute,
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
              CancelShippingOperationListScreen(
                embedded: true,
                selectedOperationId: selectedId,
                onSelectOperation: onSelect,
                onBindRefresh: bindRefresh,
                onEmbeddedCreate: onRequestCreate,
              ),
          detailViewBuilder: (context, id) => CancelShippingOperationDetailScreen(
            key: ValueKey(id),
            operationId: id,
            embedded: true,
          ),
          detailAwaitBuilder: (context) => const CancelShippingOperationDetailScreen(
            key: ValueKey('__cancel_shipping_split_await__'),
            embedded: true,
            awaitingSelection: true,
          ),
        ),
        fallback: const CancelShippingOperationListScreen(),
      ),
    );
  }
}
