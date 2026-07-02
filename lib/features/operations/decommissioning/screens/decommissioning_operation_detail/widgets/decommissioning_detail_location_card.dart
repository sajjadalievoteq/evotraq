import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_info_row_copy.dart';

class DecommissioningDetailLocationCard extends StatelessWidget {
  const DecommissioningDetailLocationCard({
    super.key,
    required this.operation,
  });

  final DecommissioningResponse operation;

  @override
  Widget build(BuildContext context) {
    final locationGlnCode =
        operation.locationGLN ?? operation.operationLocation?.glnCode;

    return DecommissioningDetailGroupCard(
      title: 'Location',
      children: [
        if (locationGlnCode != null)
          DecommissioningDetailInfoRowCopy(
            label: 'Location GLN',
            value: locationGlnCode,
          ),
        if (operation.operationLocation?.locationName?.isNotEmpty == true)
          DecommissioningDetailInfoRow(
            label: 'Facility',
            value: operation.operationLocation!.locationName!,
          ),
        if (operation.operationLocation?.city?.isNotEmpty == true)
          DecommissioningDetailInfoRow(
            label: 'City',
            value: operation.operationLocation!.city!,
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
