import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_epc_type_utils.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_field.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_info_row.dart';

class OperationReviewOptionalFields extends StatelessWidget {
  const OperationReviewOptionalFields(this.fields, {super.key});

  final List<OperationReviewField> fields;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in fields)
          if (field.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            OperationReviewInfoRow(field.label, field.value),
          ],
      ],
    );
  }
}
