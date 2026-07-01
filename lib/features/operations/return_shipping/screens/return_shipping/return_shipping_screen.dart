import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/return_shipping/cubit/return_shipping_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/return_shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_list/return_shipping_operation_list_screen.dart';

class ReturnShippingScreen extends StatefulWidget {
  const ReturnShippingScreen({super.key});

  @override
  State<ReturnShippingScreen> createState() => _ReturnShippingScreenState();
}

class _ReturnShippingScreenState extends State<ReturnShippingScreen> {
  late final ReturnShippingOperationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ReturnShippingOperationsCubit();
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
        split: Gs1SplitViewScreen<ReturnShippingOperationsCubit, ReturnShippingOperationsState>(
          appBarTitle: 'Return Shipping',
          fabHeroTag: 'return_shipping_fab',
          fabAddTooltip: 'New Return Shipping',
          fabCloseTooltip: 'Close create panel',
          createHeaderText: 'New Return Shipping',
          closeCreateTooltip: 'Close',
          emptyNoMatchText: 'No Return Shipping match your search.',
          fabNavigateRoute: Constants.opReturnShippingCreateRoute,
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
              ReturnShippingOperationListScreen(
                embedded: true,
                selectedOperationId: selectedId,
                onSelectOperation: onSelect,
                onBindRefresh: bindRefresh,
                onEmbeddedCreate: onRequestCreate,
              ),
          detailViewBuilder: (context, id) => ReturnShippingOperationDetailScreen(
            key: ValueKey(id),
            operationId: id,
            embedded: true,
          ),
          detailAwaitBuilder: (context) => const ReturnShippingOperationDetailScreen(
            key: ValueKey('__return_shipping_split_await__'),
            embedded: true,
            awaitingSelection: true,
          ),
        ),
        fallback: const ReturnShippingOperationListScreen(),
      ),
    );
  }
}
