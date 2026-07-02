import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_info_row_copy.dart';

/// ReturnShipping location card for shipping operation detail.
class ReturnShippingDetailLocationCard extends StatelessWidget {
  const ReturnShippingDetailLocationCard({
    super.key,
    required this.operation,
  });

  final ReturnShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    final sourceGlnCode =
        operation.sourceGLN ?? operation.sourceLocation?.glnCode;
    final destinationGlnCode =
        operation.destinationGLN ?? operation.destinationLocation?.glnCode;

    return ReturnShippingDetailGroupCard(
      title: 'Return Shipping Locations',
      children: [
        if (sourceGlnCode != null)
          ReturnShippingDetailInfoRowCopy(label: 'Ship From GLN', value: sourceGlnCode),
        if (operation.sourceLocation?.locationName?.isNotEmpty == true)
          ReturnShippingDetailInfoRow(
            label: 'From Facility',
            value: operation.sourceLocation!.locationName!,
          ),
        if (operation.sourceLocation?.city?.isNotEmpty == true)
          ReturnShippingDetailInfoRow(
            label: 'From City',
            value: operation.sourceLocation!.city!,
          ),
        const ReturnShippingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (destinationGlnCode != null)
          ReturnShippingDetailInfoRowCopy(label: 'Ship To GLN', value: destinationGlnCode),
        if (operation.destinationLocation?.locationName?.isNotEmpty == true)
          ReturnShippingDetailInfoRow(
            label: 'To Facility',
            value: operation.destinationLocation!.locationName!,
          ),
        if (operation.destinationLocation?.city?.isNotEmpty == true)
          ReturnShippingDetailInfoRow(
            label: 'To City',
            value: operation.destinationLocation!.city!,
          ),
      ],
    );
  }
}
