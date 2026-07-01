import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_info_row_copy.dart';

class DecommissioningDetailLocationCard extends StatelessWidget {
  const DecommissioningDetailLocationCard({
    super.key,
    required this.operation,
    required this.locationGlnDetails,
  });

  final DecommissioningResponse operation;
  final GLN? locationGlnDetails;

  @override
  Widget build(BuildContext context) {
    return DecommissioningDetailGroupCard(
      title: 'Location',
      children: [
        if (operation.locationGLN != null)
          DecommissioningDetailInfoRowCopy(
            label: 'Location GLN',
            value: operation.locationGLN!,
          ),
        if (locationGlnDetails?.locationName.isNotEmpty == true)
          DecommissioningDetailInfoRow(
            label: 'Facility',
            value: locationGlnDetails!.locationName,
          ),
        if (locationGlnDetails?.city.isNotEmpty == true)
          DecommissioningDetailInfoRow(
            label: 'City',
            value: locationGlnDetails!.city,
          ),
        if (operation.disposition != null)
          DecommissioningDetailInfoRow(
            label: 'Disposition',
            value: operation.disposition!,
          ),
        if (operation.reason != null)
          DecommissioningDetailInfoRow(
            label: 'Reason',
            value: operation.reason!,
          ),
      ],
    );
  }
}
