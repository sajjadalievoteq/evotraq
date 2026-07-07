import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/home/utils/home_navigation.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/quick_actions/widgets/dashboard_quick_action_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = [
      DashboardQuickAction(
        iconAsset: AppAssets.iconGtin,
        title: HomeStrings.quickActionGtinTitle,
        subtitle: HomeStrings.quickActionGtinSubtitle,
        color: Colors.blue,
        route: HomeNavigation.gs1Gtins,
        isDisabled: false,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconGln,
        title: HomeStrings.quickActionGlnTitle,
        color: Colors.green,
        route: HomeNavigation.gs1Glns,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconSgtin,
        title: HomeStrings.quickActionSgtinTitle,
        color: Colors.orange,
        route: HomeNavigation.gs1Sgtins,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconSscc,
        title: HomeStrings.quickActionSsccTitle,
        color: Colors.purple,
        route: HomeNavigation.gs1Ssccs,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconShipment,
        title: HomeStrings.quickActionCreateShipment,
        color: Colors.indigo,
        route: HomeNavigation.opShippingCreate,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconReceive,
        title: HomeStrings.quickActionReceiveShipment,
        color: Colors.teal,
        route: HomeNavigation.opReceivingCreate,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconArrowUpR,
        title: HomeStrings.quickActionReturnShipping,
        color: Colors.blueGrey,
        route: HomeNavigation.opReturnShippingCreate,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconReceive,
        title: HomeStrings.quickActionReturnReceiving,
        color: Colors.blueGrey,
        route: HomeNavigation.opReturnReceivingCreate,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconAggregate,
        title: HomeStrings.quickActionPacking,
        color: Colors.deepOrange,
        route: HomeNavigation.opPackingCreate,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconTransform,
        title: HomeStrings.quickActionUnpacking,
        color: Colors.brown,
        route: HomeNavigation.opUnpackingCreate,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconSparkle,
        title: HomeStrings.quickActionCommissioning,
        color: Colors.cyan,
        route: HomeNavigation.opCommissioningNew,
      ),
      DashboardQuickAction(
        iconAsset: AppAssets.iconTrash,
        title: HomeStrings.quickActionUpdateStatus,
        color: Colors.redAccent,
        route: HomeNavigation.opUpdateStatusCreate,
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

        return GridView.builder(
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
            return DashboardQuickActionCard(action: actions[index]);
          },
        );
      },
    );
  }
}
