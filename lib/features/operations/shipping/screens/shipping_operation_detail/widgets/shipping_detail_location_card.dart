import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row_copy.dart';

/// Shipping location card for shipping operation detail.
class ShippingDetailLocationCard extends StatelessWidget {
  const ShippingDetailLocationCard({
    super.key,
    required this.operation,
  });

  final ShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    final sourceGlnCode =
        operation.sourceGLN ?? operation.sourceLocation?.glnCode;
    final destinationGlnCode =
        operation.destinationGLN ?? operation.destinationLocation?.glnCode;

    return ShippingDetailGroupCard(
      title: 'Shipping Locations',
      children: [
        if (sourceGlnCode != null)
          ShippingDetailInfoRowCopy(label: 'Ship From GLN', value: sourceGlnCode),
        if (operation.sourceLocation?.locationName?.isNotEmpty == true)
          ShippingDetailInfoRow(
            label: 'From Facility',
            value: operation.sourceLocation!.locationName!,
          ),
        if (operation.sourceLocation?.city?.isNotEmpty == true)
          ShippingDetailInfoRow(
            label: 'From City',
            value: operation.sourceLocation!.city!,
          ),
        const ShippingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (destinationGlnCode != null)
          ShippingDetailInfoRowCopy(label: 'Ship To GLN', value: destinationGlnCode),
        if (operation.destinationLocation?.locationName?.isNotEmpty == true)
          ShippingDetailInfoRow(
            label: 'To Facility',
            value: operation.destinationLocation!.locationName!,
          ),
        if (operation.destinationLocation?.city?.isNotEmpty == true)
          ShippingDetailInfoRow(
            label: 'To City',
            value: operation.destinationLocation!.city!,
          ),
      ],
    );
  }
}
