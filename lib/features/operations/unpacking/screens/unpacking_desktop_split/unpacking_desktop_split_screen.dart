import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_desktop_split_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/unpacking_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_list/unpacking_operation_list_screen.dart';

class UnpackingDesktopSplitScreen extends StatelessWidget {
  const UnpackingDesktopSplitScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationDesktopSplitScreen(
        title: 'Unpacking Operation',
        createRoute: Constants.opUnpackingCreateRoute,
        listBuilder: ({
          required embedded,
          required selectedId,
          required onSelect,
          required onLoadingChanged,
        }) =>
            UnpackingOperationListScreen(
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
            UnpackingOperationDetailScreen(
              key: ValueKey(selectedId ?? '__await__'),
              operationId: selectedId,
              embedded: embedded,
              awaitingSelection: awaitingSelection,
              listLoading: listLoading,
            ),
      );
}
