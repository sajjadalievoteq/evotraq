import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/operations/shipping/cubit/shipping_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_list/shipping_operation_list_screen.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  late final ShippingOperationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ShippingOperationsCubit();
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
        split: Gs1SplitViewScreen<ShippingOperationsCubit, ShippingOperationsState>(
          appBarTitle: 'Shipping Operations',
          fabHeroTag: 'shipping_fab',
          fabAddTooltip: 'New shipping operation',
          fabCloseTooltip: 'Close create panel',
          createHeaderText: 'New Shipping Operation',
          closeCreateTooltip: 'Close',
          emptyNoMatchText: 'No shipping operations match your search.',
          fabNavigateRoute: Constants.opShippingCreateRoute,
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
              ShippingOperationListScreen(
                embedded: true,
                selectedOperationId: selectedId,
                onSelectOperation: onSelect,
                onBindRefresh: bindRefresh,
                onEmbeddedCreate: onRequestCreate,
              ),
          detailViewBuilder: (context, id) => ShippingOperationDetailScreen(
            key: ValueKey(id),
            operationId: id,
            embedded: true,
          ),
          detailAwaitBuilder: (context) => const ShippingOperationDetailScreen(
            key: ValueKey('__shipping_split_await__'),
            embedded: true,
            awaitingSelection: true,
          ),
        ),
        fallback: const ShippingOperationListScreen(),
      ),
    );
  }
}
