import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row_copy.dart';

/// Shipping location card for shipping operation detail.
class ShippingDetailLocationCard extends StatelessWidget {
  const ShippingDetailLocationCard({
    super.key,
    required this.operation,
    required this.sourceGlnDetails,
    required this.destinationGlnDetails,
  });

  final ShippingResponse operation;
  final GLN? sourceGlnDetails;
  final GLN? destinationGlnDetails;

  @override
  Widget build(BuildContext context) {
    return ShippingDetailGroupCard(
      title: 'Shipping Locations',
      children: [
        if (operation.sourceGLN != null)
          ShippingDetailInfoRowCopy(label: 'Ship From GLN', value: operation.sourceGLN!),
        if (sourceGlnDetails?.locationName.isNotEmpty == true)
          ShippingDetailInfoRow(label: 'From Facility', value: sourceGlnDetails!.locationName),
        if (sourceGlnDetails?.city.isNotEmpty == true)
          ShippingDetailInfoRow(label: 'From City', value: sourceGlnDetails!.city),
        const ShippingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (operation.destinationGLN != null)
          ShippingDetailInfoRowCopy(label: 'Ship To GLN', value: operation.destinationGLN!),
        if (destinationGlnDetails?.locationName.isNotEmpty == true)
          ShippingDetailInfoRow(
            label: 'To Facility',
            value: destinationGlnDetails!.locationName,
          ),
        if (destinationGlnDetails?.city.isNotEmpty == true)
          ShippingDetailInfoRow(label: 'To City', value: destinationGlnDetails!.city),
      ],
    );
  }
}
