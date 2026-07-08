import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';

class OperationDetailTwoGlnLocationCard extends StatelessWidget {
  const OperationDetailTwoGlnLocationCard({
    super.key,
    required this.cardTitle,
    required this.sourceGln,
    required this.destinationGln,
    required this.sourceGlnLabel,
    required this.destinationGlnLabel,
    this.sourceLocationName,
    this.sourceCity,
    this.destinationLocationName,
    this.destinationCity,
    this.showDirectionRow = true,
  });

  final String cardTitle;
  final String? sourceGln;
  final String? destinationGln;
  final String sourceGlnLabel;
  final String destinationGlnLabel;
  final String? sourceLocationName;
  final String? sourceCity;
  final String? destinationLocationName;
  final String? destinationCity;
  final bool showDirectionRow;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: cardTitle,
      children: [
        if (sourceGln != null)
          OperationDetailInfoRowCopy(label: sourceGlnLabel, value: sourceGln!),
        if (sourceLocationName?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'From Facility', value: sourceLocationName!),
        if (sourceCity?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'From City', value: sourceCity!),
        if (showDirectionRow)
          const OperationDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (destinationGln != null)
          OperationDetailInfoRowCopy(
            label: destinationGlnLabel,
            value: destinationGln!,
          ),
        if (destinationLocationName?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'To Facility', value: destinationLocationName!),
        if (destinationCity?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'To City', value: destinationCity!),
      ],
    );
  }
}
