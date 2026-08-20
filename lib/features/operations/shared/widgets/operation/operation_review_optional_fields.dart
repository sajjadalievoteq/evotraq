import 'package:flutter/material.dart';
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
