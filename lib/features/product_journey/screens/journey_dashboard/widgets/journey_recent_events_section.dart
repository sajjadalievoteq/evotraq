import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey_dashboard/widgets/journey_recent_events_loading.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey_dashboard/widgets/journey_empty_state.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey_dashboard/widgets/journey_recent_event_card.dart';

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
      return const JourneyRecentEventsLoading();
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
          padding: EdgeInsets.fromLTRB(
            context.padding.left,
            16,
            context.padding.left,
            0,
          ),
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
            padding: EdgeInsets.fromLTRB(
              context.padding.left,
              16,
              context.padding.left,
              0,
            ),
            itemCount: actionable.length,
            itemBuilder: (context, index) {
              final event = actionable[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == actionable.length - 1
                      ? context.padding.left
                      : 0,
                ),
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
