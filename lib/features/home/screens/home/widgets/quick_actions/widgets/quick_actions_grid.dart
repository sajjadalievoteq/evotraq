import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/home/utils/home_navigation.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/quick_actions/widgets/dashboard_quick_action_card.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const _allActions = [
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final actions = _allActions
        .where(
          (action) => auth.canPerform(
            OperationPermissions.stepForOperationType(action.type),
          ),
        )
        .toList(growable: false);

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        const minTileWidth = 170.0;
        const maxCols = 6;

        final maxW = constraints.maxWidth;
        // Column count follows the available width so wide screens fill the
        // row instead of stretching a fixed three columns.
        final crossAxisCount = ((maxW + gap) / (minTileWidth + gap))
            .floor()
            .clamp(maxW >= 300 ? 2 : 1, maxCols);

        final tileWidth = (maxW - gap * (crossAxisCount - 1)) / crossAxisCount;
        // Height is capped so wide tiles stay compact instead of growing
        // proportionally with the available width.
        final tileHeight = (tileWidth / 3).clamp(72.0, 92.0);

        return SelectionContainer.disabled(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: tileHeight,
              crossAxisSpacing: gap,
              mainAxisSpacing: gap,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return DashboardQuickActionCard(
                action: DashboardQuickAction(
                  iconAsset: AppColorMapper.operationTypeIcon(action.type),
                  title: action.title,
                  color: AppColorMapper.operationTypeColor(
                    context,
                    action.type,
                  ),
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
