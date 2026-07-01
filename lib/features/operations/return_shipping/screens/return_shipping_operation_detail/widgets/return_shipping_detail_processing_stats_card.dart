import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/return_shipping/utils/return_shipping_status_utils.dart';

/// Processing info card for shipping operation detail.
class ReturnShippingDetailProcessingStatsCard extends StatelessWidget {
  const ReturnShippingDetailProcessingStatsCard({
    super.key,
    required this.operation,
  });

  final ReturnShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReturnShippingDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (operation.processingTimeMs != null)
          ReturnShippingDetailInfoRow(
            label: 'Processing Time',
            value: '${operation.processingTimeMs} ms',
          ),
        ReturnShippingDetailInfoRow(
          label: 'Status',
          value: ReturnShippingStatusUtils.detailLabel(operation.status),
        ),
      ],
    );
  }
}
