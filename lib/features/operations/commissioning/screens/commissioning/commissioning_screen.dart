import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/commissioning_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/commissioning_operation_list_screen.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';

class CommissioningScreen extends StatelessWidget {
  const CommissioningScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        appBarTitle: 'Commissioning',
        fabHeroTag: 'commissioning_fab',
        fabAddTooltip: 'New commissioning operation',
        createHeaderText: 'New Commissioning Operation',
        emptyNoMatchText: 'No commissioning operations match your search.',
        fabNavigateRoute: Constants.opCommissioningNewRoute,
        listBuilder: (context, {
          required selectedId,
          required onSelect,
          required bindRefresh,
          required onRequestCreate,
        }) =>
            CommissioningOperationListScreen(
          embedded: true,
          selectedBatchId: selectedId,
          onSelectOperation: onSelect,
          onBindRefresh: bindRefresh,
          onEmbeddedCreate: onRequestCreate,
        ),
        detailViewBuilder: (context, id) => CommissioningOperationDetailScreen(
          key: ValueKey(id),
          batchId: id,
          embedded: true,
        ),
        detailAwaitBuilder: (context, {required listLoading}) =>
            CommissioningOperationDetailScreen(
          key: const ValueKey('__commissioning_split_await__'),
          embedded: true,
          awaitingSelection: true,
          listLoading: listLoading,
        ),
        fallbackList: const CommissioningOperationListScreen(),
      );
}
