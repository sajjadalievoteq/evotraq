import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/packing_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/packing_operation_list_screen.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_desktop_split_screen.dart';

class PackingDesktopSplitScreen extends StatelessWidget {
  const PackingDesktopSplitScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationDesktopSplitScreen(
        title: 'Packing Operation',
        createRoute: Constants.opPackingCreateRoute,
        listBuilder: ({
          required embedded,
          required selectedId,
          required onSelect,
          required onLoadingChanged,
        }) =>
            PackingOperationListScreen(
              embedded: embedded,
              selectedOperationId: selectedId,
              onSelectOperation: onSelect,
              onLoadingChanged: onLoadingChanged,
            ),
        detailBuilder: ({
          required selectedId,
          required embedded,
          required awaitingSelection,
          required listLoading,
        }) =>
            PackingOperationDetailScreen(
              key: ValueKey(selectedId ?? '__await__'),
              operationId: selectedId,
              embedded: embedded,
              awaitingSelection: awaitingSelection,
              listLoading: listLoading,
            ),
      );
}
