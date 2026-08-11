import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_recent_event_card_row.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/features/epcis/utils/epcis_event_ui_utils.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_selection_style.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';

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
