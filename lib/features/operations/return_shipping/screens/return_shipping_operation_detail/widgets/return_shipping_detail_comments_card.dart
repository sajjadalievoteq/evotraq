import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_info_row.dart';

/// Comments card for shipping operation detail.
class ReturnShippingDetailCommentsCard extends StatelessWidget {
  const ReturnShippingDetailCommentsCard({
    super.key,
    required this.operation,
  });

  final ReturnShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReturnShippingDetailGroupCard(
      title: 'Comments',
      children: [
        ReturnShippingDetailInfoRow(label: 'Notes', value: operation.comments!),
      ],
    );
  }
}
