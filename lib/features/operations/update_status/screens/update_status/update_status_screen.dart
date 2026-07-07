import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation_detail/update_status_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation_list/update_status_operation_list_screen.dart';

class UpdateStatusScreen extends StatelessWidget {
  const UpdateStatusScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        appBarTitle: 'Update Status Operations',
        fabHeroTag: 'update_status_fab',
        fabAddTooltip: 'New update status operation',
        createHeaderText: 'New Update Status Operation',
        emptyNoMatchText: 'No update status operations match your search.',
        fabNavigateRoute: Constants.opUpdateStatusCreateRoute,
        listBuilder: (context, {
          required selectedId,
          required onSelect,
          required bindRefresh,
          required onRequestCreate,
        }) =>
            UpdateStatusOperationListScreen(
          embedded: true,
          selectedOperationId: selectedId,
          onSelectOperation: onSelect,
          onBindRefresh: bindRefresh,
          onEmbeddedCreate: onRequestCreate,
        ),
        detailViewBuilder: (context, id) => UpdateStatusOperationDetailScreen(
          key: ValueKey(id),
          operationId: id,
          embedded: true,
        ),
        detailAwaitBuilder: (context) => UpdateStatusOperationDetailScreen(
          key: const ValueKey('__update_status_split_await__'),
          embedded: true,
          awaitingSelection: true,
        ),
        fallbackList: const UpdateStatusOperationListScreen(),
      );
}
