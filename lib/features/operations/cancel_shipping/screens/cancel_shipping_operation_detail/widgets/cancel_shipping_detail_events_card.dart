import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_group_card.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// EPCIS events card for shipping operation detail.
class CancelShippingDetailEventsCard extends StatelessWidget {
  const CancelShippingDetailEventsCard({
    super.key,
    required this.operation,
  });

  final CancelShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    final ids = operation.eventIds ?? [];

    return CancelShippingDetailGroupCard(
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
