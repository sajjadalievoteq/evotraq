import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_info_row_copy.dart';

/// CancelShipping location card for shipping operation detail.
class CancelShippingDetailLocationCard extends StatelessWidget {
  const CancelShippingDetailLocationCard({
    super.key,
    required this.operation,
    required this.sourceGlnDetails,
    required this.destinationGlnDetails,
  });

  final CancelShippingResponse operation;
  final GLN? sourceGlnDetails;
  final GLN? destinationGlnDetails;

  @override
  Widget build(BuildContext context) {
    return CancelShippingDetailGroupCard(
      title: 'Cancel Shipping Locations',
      children: [
        if (operation.sourceGLN != null)
          CancelShippingDetailInfoRowCopy(label: 'Ship From GLN', value: operation.sourceGLN!),
        if (sourceGlnDetails?.locationName.isNotEmpty == true)
          CancelShippingDetailInfoRow(label: 'From Facility', value: sourceGlnDetails!.locationName),
        if (sourceGlnDetails?.city.isNotEmpty == true)
          CancelShippingDetailInfoRow(label: 'From City', value: sourceGlnDetails!.city),
        const CancelShippingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (operation.destinationGLN != null)
          CancelShippingDetailInfoRowCopy(label: 'Ship To GLN', value: operation.destinationGLN!),
        if (destinationGlnDetails?.locationName.isNotEmpty == true)
          CancelShippingDetailInfoRow(
            label: 'To Facility',
            value: destinationGlnDetails!.locationName,
          ),
        if (destinationGlnDetails?.city.isNotEmpty == true)
          CancelShippingDetailInfoRow(label: 'To City', value: destinationGlnDetails!.city),
      ],
    );
  }
}
