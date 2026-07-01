import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_group_card.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// EPCIS events card for Receiving operation detail.
class ReceivingDetailEventsCard extends StatelessWidget {
  const ReceivingDetailEventsCard({
    super.key,
    required this.operation,
  });

  final ReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    final ids = operation.eventIds ?? [];

    return ReceivingDetailGroupCard(
      title: 'EPCIS Events (${ids.length})',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ids
              .map(
                (id) => ActionChip(
                  avatar: TraqIcon(AppAssets.iconAggregate, size: 14),
                  label: Text(
                    id.length > 16 ? '…${id.substring(id.length - 16)}' : id,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () =>
                      context.go('${Constants.epcisObjectEventsRoute}/$id'),
                  tooltip: id,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
