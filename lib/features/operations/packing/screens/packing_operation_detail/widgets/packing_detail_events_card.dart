import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_group_card.dart';

/// EPCIS events card for packing operation detail.
class PackingDetailEventsCard extends StatelessWidget {
  const PackingDetailEventsCard({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    final ids = operation.eventIds ?? [];

    return PackingDetailGroupCard(
      title: 'EPCIS Events (${ids.length})',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ids
              .map(
                (id) => ActionChip(
                  avatar: const Icon(Icons.link, size: 14),
                  label: Text(
                    id.length > 16 ? '…${id.substring(id.length - 16)}' : id,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () =>
                      context.go('${Constants.epcisAggregationEventsRoute}/$id'),
                  tooltip: id,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
