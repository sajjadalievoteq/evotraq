import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/unpacking_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_list/unpacking_operation_list_screen.dart';

class UnpackingScreen extends StatelessWidget {
  const UnpackingScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        appBarTitle: 'Unpacking Operations',
        fabHeroTag: 'unpacking_fab',
        fabAddTooltip: 'New unpacking operation',
        createHeaderText: 'New Unpacking Operation',
        emptyNoMatchText: 'No unpacking operations match your search.',
        fabNavigateRoute: Constants.opUnpackingCreateRoute,
        listBuilder: (context, {
          required selectedId,
          required onSelect,
          required bindRefresh,
          required onRequestCreate,
        }) =>
            UnpackingOperationListScreen(
          embedded: true,
          selectedOperationId: selectedId,
          onSelectOperation: onSelect,
          onBindRefresh: bindRefresh,
          onEmbeddedCreate: onRequestCreate,
        ),
        detailViewBuilder: (context, id) => UnpackingOperationDetailScreen(
          key: ValueKey(id),
          operationId: id,
          embedded: true,
        ),
        detailAwaitBuilder: (context, {required listLoading}) =>
            UnpackingOperationDetailScreen(
          key: const ValueKey('__unpacking_split_await__'),
          embedded: true,
          awaitingSelection: true,
          listLoading: listLoading,
        ),
        fallbackList: const UnpackingOperationListScreen(),
      );
}
