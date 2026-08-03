import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';

class NotificationCenterEmptyState extends StatelessWidget {
  const NotificationCenterEmptyState({
    super.key,
    required this.totalSubscriptions,
    required this.selectedFilter,
    required this.onClearFilters,
    required this.onPrimaryAction,
  });

  final int totalSubscriptions;
  final String selectedFilter;
  final VoidCallback onClearFilters;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedFilter != 'all';
    return AppEmptyState(
      iconAsset: NavIcons.notifications,
      title: 'No matching subscriptions',
      subtitle: 'Create alert subscriptions to track delivery activity.',
      hasItems: totalSubscriptions > 0,
      hasActiveFilters: hasActiveFilters,
      filteredTitle: 'No matching subscriptions',
      filteredSubtitle: 'Try a different filter or clear filters.',
      onClearFilters: hasActiveFilters ? onClearFilters : null,
      primaryActionLabel: 'Create Subscription',
      primaryActionIconAsset: AppAssets.iconPlus,
      onPrimaryAction: onPrimaryAction,
    );
  }
}
