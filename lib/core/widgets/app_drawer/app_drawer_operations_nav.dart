import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_navigation_icon.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_operation_item.dart';
import 'package:traqtrace_app/core/widgets/traq_expansion_tile.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';

class AppDrawerOperationsNav extends StatelessWidget {
  const AppDrawerOperationsNav({
    required this.authState,
    required this.surfaceColor,
    required this.onNavigate,
    super.key,
  });

  final AuthState authState;
  final Color surfaceColor;
  final ValueChanged<String> onNavigate;

  bool _can(String step) => authState.canPerform(step);

  @override
  Widget build(BuildContext context) {
    final lifecycle = <Widget>[
      if (_can(OperationSteps.commission))
        AppDrawerOperationItem(
          icon: NavIcons.commissioning,
          label: 'Commissioning',
          route: Constants.opCommissioningRoute,
          onNavigate: onNavigate,
        ),
      if (_can(OperationSteps.updateStatus))
        AppDrawerOperationItem(
          icon: NavIcons.updateStatus,
          label: 'Status Updating',
          route: Constants.opUpdateStatusRoute,
          onNavigate: onNavigate,
        ),
    ];
    final packaging = <Widget>[
      if (_can(OperationSteps.pack))
        AppDrawerOperationItem(
          icon: NavIcons.packing,
          label: 'Packing',
          route: Constants.opPackingRoute,
          onNavigate: onNavigate,
        ),
      if (_can(OperationSteps.unpack))
        AppDrawerOperationItem(
          icon: NavIcons.unpacking,
          label: 'Unpacking',
          route: Constants.opUnpackingRoute,
          onNavigate: onNavigate,
        ),
    ];
    final shippings = <Widget>[
      if (_can(OperationSteps.ship))
        AppDrawerOperationItem(
          icon: NavIcons.shipping,
          label: 'Shipping',
          route: Constants.opShippingRoute,
          onNavigate: onNavigate,
        ),
      if (_can(OperationSteps.returnShip))
        AppDrawerOperationItem(
          icon: NavIcons.returnShipping,
          label: 'Return Shipping',
          route: Constants.opReturnShippingRoute,
          onNavigate: onNavigate,
        ),
      if (_can(OperationSteps.cancelShip))
        AppDrawerOperationItem(
          icon: NavIcons.cancelShipping,
          label: 'Cancel Shipping',
          route: Constants.opCancelShippingRoute,
          onNavigate: onNavigate,
        ),
    ];
    final receivings = <Widget>[
      if (_can(OperationSteps.receive))
        AppDrawerOperationItem(
          icon: NavIcons.receiving,
          label: 'Receiving',
          route: Constants.opReceivingRoute,
          onNavigate: onNavigate,
        ),
      if (_can(OperationSteps.returnReceive))
        AppDrawerOperationItem(
          icon: NavIcons.returnReceiving,
          label: 'Return Receiving',
          route: Constants.opReturnReceivingRoute,
          onNavigate: onNavigate,
        ),
      if (_can(OperationSteps.cancelReceive))
        AppDrawerOperationItem(
          icon: NavIcons.cancelReceiving,
          label: 'Cancel Receiving',
          route: Constants.opCancelReceivingRoute,
          onNavigate: onNavigate,
        ),
    ];
    final logistics = <Widget>[
      if (shippings.isNotEmpty)
        TraqExpansionTile(
          backgroundColor: surfaceColor,
          leading: const AppDrawerNavigationIcon(NavIcons.shippings),
          title: const Text('Shippings'),
          children: shippings,
        ),
      if (receivings.isNotEmpty)
        TraqExpansionTile(
          leading: const AppDrawerNavigationIcon(NavIcons.receivings),
          title: const Text('Receivings'),
          children: receivings,
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lifecycle.isNotEmpty)
          TraqExpansionTile(
            leading: const AppDrawerNavigationIcon(NavIcons.lifecycle),
            title: const Text('Lifecycle'),
            children: lifecycle,
          ),
        if (packaging.isNotEmpty)
          TraqExpansionTile(
            leading: const AppDrawerNavigationIcon(NavIcons.packaging),
            title: const Text('Packaging'),
            children: packaging,
          ),
        if (logistics.isNotEmpty)
          TraqExpansionTile(
            leading: const AppDrawerNavigationIcon(NavIcons.logistics),
            title: const Text('Logistics'),
            childrenPadding: const EdgeInsets.only(left: 22),
            children: logistics,
          ),
      ],
    );
  }
}
