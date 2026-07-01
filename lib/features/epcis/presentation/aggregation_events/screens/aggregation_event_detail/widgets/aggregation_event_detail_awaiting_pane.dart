import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class AggregationEventDetailAwaitingPane extends StatelessWidget {
  const AggregationEventDetailAwaitingPane({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(AppAssets.iconLayers, color: Colors.grey, size: 48),
          SizedBox(height: 12),
          Text(
            'Select an event from the list',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
