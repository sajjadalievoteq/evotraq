import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/empty_state/empty_state_visual.dart';

/// Empty / awaiting-selection placeholder for detail panes (not a loading state).
/// Detail loading must use the feature's detail skeleton, not this widget.
class AppEmptyDetail extends StatelessWidget {
  const AppEmptyDetail({
    super.key,
    required this.title,
    this.subtitle,
    this.iconAsset = NavIcons.packaging,
    this.actionLabel,
    this.onAction,
    this.density = EmptyStateDensity.auto,
  });

  final String title;
  final String? subtitle;
  final String iconAsset;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateDensity density;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (actionLabel != null && onAction != null) {
      actions.add(
        EmptyStateHoverAction(
          child: CustomButtonWidget(
            title: actionLabel!,
            iconAsset: AppAssets.iconRefresh,
            onTap: onAction,
          ),
        ),
      );
    }

    return EmptyStateVisualScaffold(
      iconAsset: iconAsset,
      title: title,
      subtitle: subtitle ??
          'Choose an item from the list to see its details.',
      actions: actions,
      density: density,
      semanticsLabel: title,
    );
  }
}
