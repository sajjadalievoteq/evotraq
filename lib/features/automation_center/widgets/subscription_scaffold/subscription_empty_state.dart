import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';

class SubscriptionEmptyState extends StatelessWidget {
  const SubscriptionEmptyState({
    super.key,
    required this.totalSubscriptions,
    required this.selectedFilter,
    required this.title,
    required this.subtitle,
    required this.onClearFilters,
    required this.onPrimaryAction,
    this.filteredTitle = 'No matching subscriptions',
    this.filteredSubtitle = 'Try a different filter or clear filters.',
    this.primaryActionLabel = 'Create Subscription',
    this.iconAsset = NavIcons.notifications,
  });

  final int totalSubscriptions;
  final String selectedFilter;
  final String title;
  final String subtitle;
  final String filteredTitle;
  final String filteredSubtitle;
  final String primaryActionLabel;
  final String iconAsset;
  final VoidCallback onClearFilters;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedFilter != 'all';
    return AppEmptyState(
      iconAsset: iconAsset,
      title: title,
      subtitle: subtitle,
      hasItems: totalSubscriptions > 0,
      hasActiveFilters: hasActiveFilters,
      filteredTitle: filteredTitle,
      filteredSubtitle: filteredSubtitle,
      onClearFilters: hasActiveFilters ? onClearFilters : null,
      primaryActionLabel: primaryActionLabel,
      primaryActionIconAsset: AppAssets.iconPlus,
      onPrimaryAction: onPrimaryAction,
    );
  }
}
