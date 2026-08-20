import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_detail/widgets/object_event_detail_quantity_fields.dart';

class ObjectEventDetailEpcSection extends StatelessWidget {
  const ObjectEventDetailEpcSection({super.key, required this.event});

  final ObjectEvent event;

  @override
  Widget build(BuildContext context) {
    final epcList = event.epcList ?? [];
    final quantityList = event.quantityList ?? [];
    final epcClassList = event.epcClassList ?? [];
    if (epcList.isEmpty && quantityList.isEmpty && epcClassList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (epcList.isNotEmpty)
          EpcContentsCard(
            title: ObjectEventDetailUiConstants.labelEpcInstances,
            epcs: epcList,
            emptyMessage: 'No EPCs',
            hierarchyScreenTitle: 'Object Event Hierarchy',
          ),
        if (epcClassList.isNotEmpty || quantityList.isNotEmpty) ...[
          if (epcList.isNotEmpty) const SizedBox(height: 16),
          Gs1GroupCard(
            title: ObjectEventDetailUiConstants.sectionEpcs,
            outlineColor: Theme.of(context).colorScheme.outlineVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (epcClassList.isNotEmpty) ...[
                  Text(
                    '${ObjectEventDetailUiConstants.labelEpcClassesCount} (${epcClassList.length})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...epcClassList.map(
                    (epcClass) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        epcClass,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                if (quantityList.isNotEmpty) ...[
                  if (epcClassList.isNotEmpty) const SizedBox(height: 12),
                  ...quantityList.map(
                    (quantity) =>
                        ObjectEventDetailQuantityFields(quantity: quantity),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
