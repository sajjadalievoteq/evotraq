import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/empty_state/empty_state_visual.dart';

/// Professional, responsive empty / filtered-list placeholder.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.iconAsset,
    required this.title,
    this.subtitle,
    this.hasItems = false,
    this.hasActiveFilters = false,
    this.filteredTitle = 'No results found',
    this.filteredSubtitle = 'Try adjusting your search or filters.',
    this.onClearFilters,
    this.primaryActionLabel,
    this.primaryActionIconAsset,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.footer,
    this.density = EmptyStateDensity.auto,
  });

  final String iconAsset;
  final String title;
  final String? subtitle;
  final bool hasItems;
  final bool hasActiveFilters;
  final String filteredTitle;
  final String filteredSubtitle;
  final VoidCallback? onClearFilters;
  final String? primaryActionLabel;
  final String? primaryActionIconAsset;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Widget? footer;
  final EmptyStateDensity density;

  bool get _isFiltered => hasItems && hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (_isFiltered && onClearFilters != null) {
      actions.add(
        EmptyStateHoverAction(
          child: CustomButtonWidget(
            title: 'Clear Filters',
            iconAsset: AppAssets.iconRefresh,
            onTap: onClearFilters,
          ),
        ),
      );
    }

    if (!_isFiltered &&
        primaryActionLabel != null &&
        onPrimaryAction != null) {
      actions.add(
        EmptyStateHoverAction(
          child: CustomButtonWidget(
            title: primaryActionLabel!,
            iconAsset: primaryActionIconAsset,
            onTap: onPrimaryAction,
          ),
        ),
      );
    }

    if (!_isFiltered &&
        secondaryActionLabel != null &&
        onSecondaryAction != null) {
      actions.add(
        OutlinedButton(
          onPressed: onSecondaryAction,
          child: Text(secondaryActionLabel!),
        ),
      );
    }

    return EmptyStateVisualScaffold(
      iconAsset: iconAsset,
      title: _isFiltered ? filteredTitle : title,
      subtitle: _isFiltered ? filteredSubtitle : subtitle,
      actions: actions,
      footer: footer,
      density: density,
      semanticsLabel: _isFiltered ? filteredTitle : title,
    );
  }
}
