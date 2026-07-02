import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_info_row.dart';

/// Comments card for shipping operation detail.
class CancelShippingDetailCommentsCard extends StatelessWidget {
  const CancelShippingDetailCommentsCard({
    super.key,
    required this.operation,
  });

  final CancelShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return CancelShippingDetailGroupCard(
      title: 'Comments',
      children: [
        CancelShippingDetailInfoRow(label: 'Notes', value: operation.comments!),
      ],
    );
  }
}
