import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_empty_state.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_recent_event_card.dart';

/// Initial-state recent events under the journey search bar.
class JourneyRecentEventsSection extends StatelessWidget {
  const JourneyRecentEventsSection({
    super.key,
    required this.events,
    required this.isLoading,
    required this.onEventTap,
  });

  final List<RecentEvent> events;
  final bool isLoading;
  final ValueChanged<RecentEvent> onEventTap;

  static String? identifierFor(RecentEvent event) {
    for (final epc in event.epcList) {
      final text = epc.trim();
      if (text.isNotEmpty) return text;
    }
    final parent = event.parentId?.trim();
    if (parent != null && parent.isNotEmpty) return parent;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _RecentEventsLoading();
    }

    final actionable = events
        .where((e) => identifierFor(e) != null)
        .take(10)
        .toList(growable: false);

    if (actionable.isEmpty) {
      return const JourneyEmptyState();
    }

    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding:EdgeInsets.fromLTRB(context.padding.left, 16, context.padding.left, 0),
          child: Text(
            'Recent events',
            style: context.text.body.copyWith(
              fontWeight: FontWeight.w700,
              color: c.textSecondary,
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding:EdgeInsets.fromLTRB(context.padding.left, 16, context.padding.left, 0),
            itemCount: actionable.length,
            itemBuilder: (context, index) {
              final event = actionable[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index==actionable.length-1?context.padding.left:0),
                child: JourneyRecentEventCard(
                  event: event,
                  onTap: () => onEventTap(event),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentEventsLoading extends StatelessWidget {
  const _RecentEventsLoading();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:EdgeInsets.fromLTRB(context.padding.left, 16, context.padding.left, 0),
            child: AppSkeletonBox(height: 20,width: 100,radius: 6,),
          ),
          Expanded(
            child: ListView.builder(
              padding:EdgeInsets.fromLTRB(context.padding.left, 16, context.padding.left, 0),
              itemCount: 6,
              itemBuilder: (_, __) => const Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppSkeletonBox(width: 72, height: 24, radius: 12),
                          Spacer(),
                          AppSkeletonBox(width: 56, height: 14, radius: 6),
                        ],
                      ),
                      SizedBox(height: 12),
                      AppSkeletonBox(width: double.infinity, height: 20, radius: 6),
                      SizedBox(height: 8),
                      AppSkeletonBox(width: 180, height: 14, radius: 6),
                      SizedBox(height: 4),
                      AppSkeletonBox(width: 140, height: 14, radius: 6),
                      SizedBox(height: 4),
                      AppSkeletonBox(width: 120, height: 14, radius: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
