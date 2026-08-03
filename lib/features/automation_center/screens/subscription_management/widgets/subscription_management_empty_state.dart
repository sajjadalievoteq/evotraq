import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';

class SubscriptionManagementEmptyState extends StatelessWidget {
  const SubscriptionManagementEmptyState({
    super.key,
    required this.totalSubscriptions,
    required this.selectedFilter,
    required this.onClearFilters,
    required this.onCreate,
  });

  final int totalSubscriptions;
  final String selectedFilter;
  final VoidCallback onClearFilters;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedFilter != 'all';
    return AppEmptyState(
      iconAsset: NavIcons.notifications,
      title: 'No subscriptions yet',
      subtitle:
          'Create your first webhook or email subscription to get notified about EPCIS events.',
      hasItems: totalSubscriptions > 0,
      hasActiveFilters: hasActiveFilters,
      filteredTitle: 'No matching subscriptions',
      filteredSubtitle: 'Try a different filter or clear filters.',
      onClearFilters: hasActiveFilters ? onClearFilters : null,
      primaryActionLabel: 'Create Subscription',
      primaryActionIconAsset: AppAssets.iconPlus,
      onPrimaryAction: onCreate,
    );
  }
}
