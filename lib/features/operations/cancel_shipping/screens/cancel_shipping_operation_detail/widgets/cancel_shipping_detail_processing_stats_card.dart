import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/utils/cancel_shipping_status_utils.dart';

/// Processing info card for shipping operation detail.
class CancelShippingDetailProcessingStatsCard extends StatelessWidget {
  const CancelShippingDetailProcessingStatsCard({
    super.key,
    required this.operation,
  });

  final CancelShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return CancelShippingDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (operation.processingTimeMs != null)
          CancelShippingDetailInfoRow(
            label: 'Processing Time',
            value: '${operation.processingTimeMs} ms',
          ),
        CancelShippingDetailInfoRow(
          label: 'Status',
          value: CancelShippingStatusUtils.detailLabel(operation.status),
        ),
      ],
    );
  }
}
