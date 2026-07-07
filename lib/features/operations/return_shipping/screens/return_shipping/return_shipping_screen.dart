import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/return_shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_list/return_shipping_operation_list_screen.dart';

class ReturnShippingScreen extends StatelessWidget {
  const ReturnShippingScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        appBarTitle: 'Return Shipping',
        fabHeroTag: 'return_shipping_fab',
        fabAddTooltip: 'New Return Shipping',
        createHeaderText: 'New Return Shipping',
        emptyNoMatchText: 'No Return Shipping match your search.',
        fabNavigateRoute: Constants.opReturnShippingCreateRoute,
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
        detailAwaitBuilder: (context) => ReturnShippingOperationDetailScreen(
          key: const ValueKey('__return_shipping_split_await__'),
          embedded: true,
          awaitingSelection: true,
        ),
        fallbackList: const ReturnShippingOperationListScreen(),
      );
}
