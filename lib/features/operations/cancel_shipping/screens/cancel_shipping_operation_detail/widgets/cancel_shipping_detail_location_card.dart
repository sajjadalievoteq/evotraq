import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_info_row_copy.dart';

/// CancelShipping location card for shipping operation detail.
class CancelShippingDetailLocationCard extends StatelessWidget {
  const CancelShippingDetailLocationCard({
    super.key,
    required this.operation,
  });

  final CancelShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    final sourceGlnCode =
        operation.sourceGLN ?? operation.sourceLocation?.glnCode;
    final destinationGlnCode =
        operation.destinationGLN ?? operation.destinationLocation?.glnCode;

    return CancelShippingDetailGroupCard(
      title: 'Cancel Shipping Locations',
      children: [
        if (sourceGlnCode != null)
          CancelShippingDetailInfoRowCopy(label: 'Ship From GLN', value: sourceGlnCode),
        if (operation.sourceLocation?.locationName?.isNotEmpty == true)
          CancelShippingDetailInfoRow(
            label: 'From Facility',
            value: operation.sourceLocation!.locationName!,
          ),
        if (operation.sourceLocation?.city?.isNotEmpty == true)
          CancelShippingDetailInfoRow(
            label: 'From City',
            value: operation.sourceLocation!.city!,
          ),
        const CancelShippingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (destinationGlnCode != null)
          CancelShippingDetailInfoRowCopy(label: 'Ship To GLN', value: destinationGlnCode),
        if (operation.destinationLocation?.locationName?.isNotEmpty == true)
          CancelShippingDetailInfoRow(
            label: 'To Facility',
            value: operation.destinationLocation!.locationName!,
          ),
        if (operation.destinationLocation?.city?.isNotEmpty == true)
          CancelShippingDetailInfoRow(
            label: 'To City',
            value: operation.destinationLocation!.city!,
          ),
      ],
    );
  }
}
