import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_empty_state.dart';

class EmptyDeliveryFeed extends StatelessWidget {
  const EmptyDeliveryFeed({
    super.key,
    required this.hasAnyEvents,
    required this.hasCounters,
    required this.selectedFilter,
    required this.onClearFilters,
    required this.onPrimaryAction,
  });
  final bool hasAnyEvents;
  final bool hasCounters;
  final String selectedFilter;
  final VoidCallback onClearFilters;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    if (hasAnyEvents) {
      return SubscriptionEmptyState(
        totalSubscriptions: 1,
        selectedFilter: selectedFilter,
        title: 'No matching delivery events',
        subtitle: 'Try another status filter.',
        onClearFilters: onClearFilters,
        onPrimaryAction: onPrimaryAction,
      );
    }
    final subtitle = hasCounters
        ? 'Matched / Delivered counters can be non-zero while this feed is '
              'empty — counters update even when no durable history row was '
              'stored (older deliveries, or retention cleanup). New deliveries '
              'after history persistence will appear here.'
        : 'When email or webhook deliveries run, each attempt shows up here.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SubscriptionEmptyState(
          totalSubscriptions: 0,
          selectedFilter: 'all',
          title: 'No delivery events yet',
          subtitle: subtitle,
          primaryActionLabel: 'Manage Subscriptions',
          onClearFilters: onClearFilters,
          onPrimaryAction: onPrimaryAction,
        ),
      ],
    );
  }
}
