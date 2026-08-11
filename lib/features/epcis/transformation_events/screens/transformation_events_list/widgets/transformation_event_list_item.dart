import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';

class TransformationEventListItem extends StatelessWidget {
  const TransformationEventListItem({
    super.key,
    required this.event,
    required this.onTap,
  });

  final TransformationEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inputCount = event.inputEPCList.length;
    final outputCount = event.outputEPCList.length;
    final formattedDate = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(event.eventTime);
    final transformColor = AppColorMapper.eventTypeColor(
      context,
      'transformation',
      scheme: AppEventColorScheme.epcis,
    );

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: transformColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TraqIcon(AppAssets.iconTransform, color: transformColor),
      ),
      title: Text(
        'ID: ${event.transformationID}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Date: $formattedDate'),
          Text('$inputCount input(s) → $outputCount output(s)'),
          if (event.businessStep != null)
            Text('Step: ${CbvDisplayUtils.displayBizStep(event.businessStep)}'),
        ],
      ),
    );
  }
}
