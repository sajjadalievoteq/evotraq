import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';
import 'package:traqtrace_app/features/home/utils/home_navigation.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/quick_actions/widgets/dashboard_quick_action_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        type: OperationType.commissioning,
        title: HomeStrings.quickActionCommissioning,
        route: HomeNavigation.opCommissioningNew,
      ),
      (
        type: OperationType.updateStatus,
        title: HomeStrings.quickActionUpdateStatus,
        route: HomeNavigation.opUpdateStatusCreate,
      ),
      (
        type: OperationType.packing,
        title: HomeStrings.quickActionPacking,
        route: HomeNavigation.opPackingCreate,
      ),
      (
        type: OperationType.unpacking,
        title: HomeStrings.quickActionUnpacking,
        route: HomeNavigation.opUnpackingCreate,
      ),
      (
        type: OperationType.shipping,
        title: HomeStrings.quickActionShipping,
        route: HomeNavigation.opShippingCreate,
      ),
      (
        type: OperationType.returnShipping,
        title: HomeStrings.quickActionReturnShipping,
        route: HomeNavigation.opReturnShippingCreate,
      ),
      (
        type: OperationType.cancelShipping,
        title: HomeStrings.quickActionCancelShipping,
        route: HomeNavigation.opCancelShippingCreate,
      ),
      (
        type: OperationType.receiving,
        title: HomeStrings.quickActionReceiving,
        route: HomeNavigation.opReceivingCreate,
      ),
      (
        type: OperationType.returnReceiving,
        title: HomeStrings.quickActionReturnReceiving,
        route: HomeNavigation.opReturnReceivingCreate,
      ),
      (
        type: OperationType.cancelReceiving,
        title: HomeStrings.quickActionCancelReceiving,
        route: HomeNavigation.opCancelReceivingCreate,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          < 360 => 2,
          < 500 => 2,
          < 700 => 2,
          < 900 => 3,
          _ => 3,
        };

        const childAspectRatio = 18 / 6;

        return SelectionContainer.disabled(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return DashboardQuickActionCard(
                action: DashboardQuickAction(
                  iconAsset: AppColorMapper.operationTypeIcon(action.type),
                  title: action.title,
                  color: AppColorMapper.operationTypeColor(context, action.type),
                  route: action.route,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
