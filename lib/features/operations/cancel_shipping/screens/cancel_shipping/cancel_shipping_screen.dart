import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/cancel_shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_list/cancel_shipping_operation_list_screen.dart';

class CancelShippingScreen extends StatelessWidget {
  const CancelShippingScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        appBarTitle: 'Cancel Shipping',
        fabHeroTag: 'cancel_shipping_fab',
        fabAddTooltip: 'New Cancellation',
        createHeaderText: 'New Cancel Shipping',
        emptyNoMatchText: 'No Cancel Shipping match your search.',
        fabNavigateRoute: Constants.opCancelShippingCreateRoute,
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
        detailAwaitBuilder: (context) => CancelShippingOperationDetailScreen(
          key: const ValueKey('__cancel_shipping_split_await__'),
          embedded: true,
          awaitingSelection: true,
        ),
        fallbackList: const CancelShippingOperationListScreen(),
      );
}
