import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/packing_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/packing_operation_list_screen.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';

class PackingScreen extends StatelessWidget {
  const PackingScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        appBarTitle: 'Packing Operations',
        fabHeroTag: 'packing_fab',
        fabAddTooltip: 'New packing operation',
        createHeaderText: 'New Packing Operation',
        emptyNoMatchText: 'No packing operations match your search.',
        fabNavigateRoute: Constants.opPackingCreateRoute,
        listBuilder: (context, {
          required selectedId,
          required onSelect,
          required bindRefresh,
          required onRequestCreate,
        }) =>
            PackingOperationListScreen(
          embedded: true,
          selectedOperationId: selectedId,
          onSelectOperation: onSelect,
          onBindRefresh: bindRefresh,
          onEmbeddedCreate: onRequestCreate,
        ),
        detailViewBuilder: (context, id) => PackingOperationDetailScreen(
          key: ValueKey(id),
          operationId: id,
          embedded: true,
        ),
        detailAwaitBuilder: (context, {required listLoading}) =>
            PackingOperationDetailScreen(
          key: const ValueKey('__packing_split_await__'),
          embedded: true,
          awaitingSelection: true,
          listLoading: listLoading,
        ),
        fallbackList: const PackingOperationListScreen(),
      );
}
