import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/utils/auth_role_context.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_entry_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_list/shipping_operation_list_screen.dart';

class ShippingScreen extends StatelessWidget {
  const ShippingScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationEntryScreen(
        showFloatingActionButton:
            context.canPerform(OperationSteps.ship),
        appBarTitle: 'Shipping Operations',
        fabHeroTag: 'shipping_fab',
        fabAddTooltip: 'New shipping operation',
        createHeaderText: 'New Shipping Operation',
        emptyNoMatchText: 'No shipping operations match your search.',
        fabNavigateRoute: Constants.opShippingCreateRoute,
        listBuilder: (context, {
          required selectedId,
          required onSelect,
          required bindRefresh,
          required onRequestCreate,
        }) =>
            ShippingOperationListScreen(
          embedded: true,
          selectedOperationId: selectedId,
          onSelectOperation: onSelect,
          onBindRefresh: bindRefresh,
          onEmbeddedCreate: context.canPerform(OperationSteps.ship)
              ? onRequestCreate
              : null,
        ),
        detailViewBuilder: (context, id) => ShippingOperationDetailScreen(
          key: ValueKey(id),
          operationId: id,
          embedded: true,
        ),
        detailAwaitBuilder: (context, {required listLoading}) => ShippingOperationDetailScreen(
          key: const ValueKey('__shipping_split_await__'),
          embedded: true,
          listLoading: listLoading,
          awaitingSelection: true,
        ),
        fallbackList: const ShippingOperationListScreen(),
      );
}
