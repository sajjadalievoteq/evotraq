import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/cancel_receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_list/cancel_receiving_operation_list_screen.dart';

class CancelReceivingScreen extends StatelessWidget {
  const CancelReceivingScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        appBarTitle: 'Cancel Receiving',
        fabHeroTag: 'cancel_receiving_fab',
        fabAddTooltip: 'New Cancellation',
        createHeaderText: 'New Cancel Receiving',
        emptyNoMatchText: 'No Cancel Receiving match your search.',
        fabNavigateRoute: Constants.opCancelReceivingCreateRoute,
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
        detailAwaitBuilder: (context) => CancelReceivingOperationDetailScreen(
          key: const ValueKey('__cancel_receiving_split_await__'),
          embedded: true,
          awaitingSelection: true,
        ),
        fallbackList: const CancelReceivingOperationListScreen(),
      );
}
