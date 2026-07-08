import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_list/receiving_operation_list_screen.dart';

class ReceivingScreen extends StatelessWidget {
  const ReceivingScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        appBarTitle: 'Receiving Operations',
        fabHeroTag: 'receiving_fab',
        fabAddTooltip: 'New Receiving operation',
        createHeaderText: 'New Receiving Operation',
        emptyNoMatchText: 'No Receiving operations match your search.',
        fabNavigateRoute: Constants.opReceivingCreateRoute,
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
        detailAwaitBuilder: (context) => ReceivingOperationDetailScreen(
          key: const ValueKey('__receiving_split_await__'),
          embedded: true,
          awaitingSelection: true,
        ),
        fallbackList: const ReceivingOperationListScreen(),
      );
}
