import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shipping/utils/shipping_status_utils.dart';

/// Processing info card for shipping operation detail.
class ShippingDetailProcessingStatsCard extends StatelessWidget {
  const ShippingDetailProcessingStatsCard({
    super.key,
    required this.operation,
  });

  final ShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ShippingDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (operation.processingTimeMs != null)
          ShippingDetailInfoRow(
            label: 'Processing Time',
            value: '${operation.processingTimeMs} ms',
          ),
        ShippingDetailInfoRow(
          label: 'Status',
          value: ShippingStatusUtils.detailLabel(operation.status),
        ),
      ],
    );
  }
}
