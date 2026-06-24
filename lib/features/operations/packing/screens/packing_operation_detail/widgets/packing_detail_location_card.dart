import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row_copy.dart';

/// Packing location card for packing operation detail.
class PackingDetailLocationCard extends StatelessWidget {
  const PackingDetailLocationCard({
    super.key,
    required this.operation,
    required this.locationGlnDetails,
  });

  final PackingResponse operation;
  final GLN? locationGlnDetails;

  @override
  Widget build(BuildContext context) {
    return PackingDetailGroupCard(
      title: 'Packing Location',
      children: [
        if (operation.packingLocationGLN != null)
          PackingDetailInfoRowCopy(label: 'GLN', value: operation.packingLocationGLN!),
        if (locationGlnDetails?.locationName.isNotEmpty == true)
          PackingDetailInfoRow(label: 'Facility', value: locationGlnDetails!.locationName),
        if (locationGlnDetails?.city.isNotEmpty == true)
          PackingDetailInfoRow(label: 'City', value: locationGlnDetails!.city),
      ],
    );
  }
}
