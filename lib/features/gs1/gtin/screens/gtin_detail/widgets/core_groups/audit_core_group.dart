import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

/// Presenter — controllers owned by [GTINDetailScreen].
class AuditCoreGroup extends StatelessWidget {
  const AuditCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.createdByController,
    required this.updatedByController,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final TextEditingController createdByController;
  final TextEditingController updatedByController;
  final bool showFieldSkeleton;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: GtinUiConstants.sectionAudit,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gs1ValidatedField(
            controller: createdByController,
            fieldName: 'created_by',
            label: GtinUiConstants.labelCreatedBy,
            readOnly: isReadOnly,
            maxLength: 64,
            validator: GtinFieldValidators.validateCreatedBy,
          ),
          const SizedBox(height: 12),
          Gs1ValidatedField(
            controller: updatedByController,
            fieldName: 'updated_by',
            label: GtinUiConstants.labelUpdatedBy,
            readOnly: isReadOnly,
            maxLength: 64,
            validator: GtinFieldValidators.validateUpdatedBy,
          ),
        ],
      ),
    );
  }
}
