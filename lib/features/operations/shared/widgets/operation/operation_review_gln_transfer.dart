import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_epc_type_utils.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_info_row.dart';

class OperationReviewGlnTransfer extends StatelessWidget {
  const OperationReviewGlnTransfer({
    super.key,
    required this.sourceLabel,
    required this.sourceGln,
    required this.destinationLabel,
    required this.destinationGln,
  });

  final String sourceLabel;
  final GLN? sourceGln;
  final String destinationLabel;
  final GLN? destinationGln;

  static TextStyle _locationNameStyle() =>
      TextStyle(color: Colors.grey[700], fontSize: 12);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OperationReviewInfoRow(sourceLabel, sourceGln?.glnCode ?? '-'),
        if (sourceGln?.locationName.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(sourceGln!.locationName, style: _locationNameStyle()),
          ),
        const SizedBox(height: 12),
        const Center(child: TraqIcon(AppAssets.iconArrowD, size: 20)),
        const SizedBox(height: 12),
        OperationReviewInfoRow(
          destinationLabel,
          destinationGln?.glnCode ?? '-',
        ),
        if (destinationGln?.locationName.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              destinationGln!.locationName,
              style: _locationNameStyle(),
            ),
          ),
      ],
    );
  }
}
