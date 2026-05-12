import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/quick_actions/widgets/dashboard_quick_action_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = [
      DashboardQuickAction(
        icon: Icons.qr_code,
        title: 'GTIN Management',
        subtitle: 'GS1 identifiers',
        color: Colors.blue,
        route: Constants.gs1GtinsRoute,
        isDisabled: false,
      ),
      DashboardQuickAction(
        icon: Icons.location_on,
        title: 'GLN Management',
        color: Colors.green,
        route: Constants.gs1GlnsRoute,
      ),
      DashboardQuickAction(
        icon: Icons.qr_code_scanner,
        title: 'SGTIN Management',
        color: Colors.orange,
        route: Constants.gs1SgtinsRoute,
      ),
      DashboardQuickAction(
        icon: Icons.inventory,
        title: 'SSCC Management',
        color: Colors.purple,
        route: Constants.gs1SsccsRoute,
      ),
      DashboardQuickAction(
        icon: Icons.local_shipping,
        title: 'Create Shipment',
        color: Colors.indigo,
        route: Constants.opShippingCreateRoute,
      ),
      DashboardQuickAction(
        icon: Icons.download,
        title: 'Receive Shipment',
        color: Colors.teal,
        route: Constants.opReceivingRoute,
      ),
      DashboardQuickAction(
        icon: Icons.inventory_2,
        title: 'Packing',
        color: Colors.deepOrange,
        route: Constants.opPackingRoute,
      ),
      DashboardQuickAction(
        icon: Icons.play_for_work,
        title: 'Commissioning',
        color: Colors.cyan,
        route: Constants.opCommissioningRoute,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          < 360 => 2,
          < 500 => 2,
          < 700 => 2,
          < 900 => 3,
          _ => 4,
        };

        // GridView childAspectRatio = width / height.
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
