import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/utils/auth_role_context.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/return_receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_list/return_receiving_operation_list_screen.dart';

class ReturnReceivingScreen extends StatelessWidget {
  const ReturnReceivingScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        showFloatingActionButton:
            context.canPerform(OperationSteps.returnReceive),
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
          onEmbeddedCreate: context.canPerform(OperationSteps.returnReceive)
              ? onRequestCreate
              : null,
        ),
        detailViewBuilder: (context, id) => ReturnReceivingOperationDetailScreen(
          key: ValueKey(id),
          operationId: id,
          embedded: true,
        ),
        detailAwaitBuilder: (context, {required listLoading}) => ReturnReceivingOperationDetailScreen(
          key: const ValueKey('__return_receiving_split_await__'),
          embedded: true,
          listLoading: listLoading,
          awaitingSelection: true,
        ),
        fallbackList: const ReturnReceivingOperationListScreen(),
      );
}
