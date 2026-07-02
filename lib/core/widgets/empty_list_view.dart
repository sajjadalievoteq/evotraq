import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
class EmptyListView extends StatelessWidget {
  const EmptyListView({
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final isFiltered = hasItems && hasActiveFilters;
    return Center(
      child: Padding(
        padding: context.horizontalPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraqIcon(
              iconAsset,
              size: 64,
              color: muted.withValues(alpha: 0.4),
            ),
            Text(
              isFiltered ? filteredTitle : title,
              style: theme.textTheme.bodyLarge?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered ? filteredSubtitle : (subtitle ?? ''),
              style: theme.textTheme.bodySmall?.copyWith(
                color: muted.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (isFiltered && onClearFilters != null) ...[
              const SizedBox(height: 24),
              CustomButtonWidget(
                title: 'Clear Filters',
                iconAsset: AppAssets.iconRefresh,
                onTap: onClearFilters!,
              ),
            ],
            if (!isFiltered &&
                primaryActionLabel != null &&
                onPrimaryAction != null) ...[
              const SizedBox(height: 24),
              CustomButtonWidget(
                title: primaryActionLabel!,
                iconAsset: primaryActionIconAsset,
                onTap: onPrimaryAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
