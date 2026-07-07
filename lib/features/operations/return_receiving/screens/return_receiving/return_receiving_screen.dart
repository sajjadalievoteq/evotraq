import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/return_receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_list/return_receiving_operation_list_screen.dart';

class ReturnReceivingScreen extends StatelessWidget {
  const ReturnReceivingScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        appBarTitle: 'Return Receiving',
        fabHeroTag: 'return_receiving_fab',
        fabAddTooltip: 'New return receiving',
        createHeaderText: 'New Return Receiving',
        emptyNoMatchText: 'No return receiving match your search.',
        fabNavigateRoute: Constants.opReturnReceivingCreateRoute,
        listBuilder: (context, {
          required selectedId,
          required onSelect,
          required bindRefresh,
          required onRequestCreate,
        }) =>
            ReturnReceivingOperationListScreen(
          embedded: true,
          selectedOperationId: selectedId,
          onSelectOperation: onSelect,
          onBindRefresh: bindRefresh,
          onEmbeddedCreate: onRequestCreate,
        ),
        detailViewBuilder: (context, id) => ReturnReceivingOperationDetailScreen(
          key: ValueKey(id),
          operationId: id,
          embedded: true,
        ),
        detailAwaitBuilder: (context) => ReturnReceivingOperationDetailScreen(
          key: const ValueKey('__return_receiving_split_await__'),
          embedded: true,
          awaitingSelection: true,
        ),
        fallbackList: const ReturnReceivingOperationListScreen(),
      );
}
