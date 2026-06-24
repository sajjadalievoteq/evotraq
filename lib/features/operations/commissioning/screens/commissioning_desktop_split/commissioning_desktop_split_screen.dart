import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/commissioning_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/commissioning_operation_list_screen.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_desktop_split_screen.dart';

class CommissioningDesktopSplitScreen extends StatelessWidget {
  const CommissioningDesktopSplitScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationDesktopSplitScreen(
        title: 'Commissioning',
        createRoute: Constants.opCommissioningNewRoute,
        readSelectedFromQuery: false,
        listBuilder: ({
          required embedded,
          required selectedId,
          required onSelect,
          required onLoadingChanged,
        }) =>
            CommissioningOperationListScreen(
              embedded: embedded,
              selectedBatchId: selectedId,
              onSelectOperation: onSelect,
              onLoadingChanged: onLoadingChanged,
            ),
        detailBuilder: ({
          required selectedId,
          required embedded,
          required awaitingSelection,
          required listLoading,
        }) =>
            CommissioningOperationDetailScreen(
              key: ValueKey(selectedId ?? '__await__'),
              batchId: selectedId,
              embedded: embedded,
              awaitingSelection: awaitingSelection,
              listLoading: listLoading,
            ),
      );
}
