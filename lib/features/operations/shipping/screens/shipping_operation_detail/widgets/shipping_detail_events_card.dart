import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_group_card.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// EPCIS events card for shipping operation detail.
class ShippingDetailEventsCard extends StatelessWidget {
  const ShippingDetailEventsCard({
    super.key,
    required this.operation,
  });

  final ShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    final ids = operation.eventIds ?? [];

    return ShippingDetailGroupCard(
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
