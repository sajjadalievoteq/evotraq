import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_navigation.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/quick_actions/widgets/dashboard_quick_action_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = [
      DashboardQuickAction(
        icon: Icons.qr_code,
        title: HomeStrings.quickActionGtinTitle,
        subtitle: HomeStrings.quickActionGtinSubtitle,
        color: Colors.blue,
        route: HomeNavigation.gs1Gtins,
        isDisabled: false,
      ),
      DashboardQuickAction(
        icon: Icons.location_on,
        title: HomeStrings.quickActionGlnTitle,
        color: Colors.green,
        route: HomeNavigation.gs1Glns,
      ),
      DashboardQuickAction(
        icon: Icons.qr_code_scanner,
        title: HomeStrings.quickActionSgtinTitle,
        color: Colors.orange,
        route: HomeNavigation.gs1Sgtins,
      ),
      DashboardQuickAction(
        icon: Icons.inventory,
        title: HomeStrings.quickActionSsccTitle,
        color: Colors.purple,
        route: HomeNavigation.gs1Ssccs,
      ),
      DashboardQuickAction(
        icon: Icons.local_shipping,
        title: HomeStrings.quickActionCreateShipment,
        color: Colors.indigo,
        route: HomeNavigation.opShippingCreate,
      ),
      DashboardQuickAction(
        icon: Icons.download,
        title: HomeStrings.quickActionReceiveShipment,
        color: Colors.teal,
        route: HomeNavigation.opReceiving,
      ),
      DashboardQuickAction(
        icon: Icons.inventory_2,
        title: HomeStrings.quickActionPacking,
        color: Colors.deepOrange,
        route: HomeNavigation.opPacking,
      ),
      DashboardQuickAction(
        icon: Icons.play_for_work,
        title: HomeStrings.quickActionCommissioning,
        color: Colors.cyan,
        route: HomeNavigation.opCommissioning,
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
