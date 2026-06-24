import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row.dart';

/// Comments card for shipping operation detail.
class ShippingDetailCommentsCard extends StatelessWidget {
  const ShippingDetailCommentsCard({
    super.key,
    required this.operation,
  });

  final ShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ShippingDetailGroupCard(
      title: 'Comments',
      children: [
        ShippingDetailInfoRow(label: 'Notes', value: operation.comments!),
      ],
    );
  }
}
