import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/empty_state/empty_state_visual.dart';

/// Empty / awaiting-selection placeholder for detail panes.
class AppEmptyDetail extends StatelessWidget {
  const AppEmptyDetail({
    super.key,
    required this.title,
    this.subtitle,
    this.iconAsset = AppAssets.iconPackage,
    this.loading = false,
    this.actionLabel,
    this.onAction,
    this.density = EmptyStateDensity.auto,
  });

  final String title;
  final String? subtitle;
  final String iconAsset;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateDensity density;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

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
