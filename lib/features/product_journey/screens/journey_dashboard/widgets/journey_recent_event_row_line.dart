import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey_dashboard/widgets/journey_recent_event_card_row.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JourneyRecentEventRowLine extends StatelessWidget {
  const JourneyRecentEventRowLine({required this.row, required this.color});

  final JourneyRecentEventCardRow row;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TraqIcon(row.iconAsset, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            row.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}
