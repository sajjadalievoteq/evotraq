import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';

class AuditCoreGroup extends StatefulWidget {
  const AuditCoreGroup({
    super.key,
    required this.isReadOnly,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;

  @override
  State<AuditCoreGroup> createState() => AuditCoreGroupState();
}

class AuditCoreGroupState extends State<AuditCoreGroup> {
  late final TextEditingController _createdBy;
  late final TextEditingController _updatedBy;

  @override
  void initState() {
    super.initState();
    _createdBy = TextEditingController();
    _updatedBy = TextEditingController();
  }

  @override
  void dispose() {
    _createdBy.dispose();
    _updatedBy.dispose();
    super.dispose();
  }

  String? get createdBy =>
      _createdBy.text.trim().isEmpty ? null : _createdBy.text.trim();
  String? get updatedBy =>
      _updatedBy.text.trim().isEmpty ? null : _updatedBy.text.trim();

  void setFromGtin({
    required String? createdBy,
    required String? updatedBy,
  }) {
    _createdBy.text = (createdBy ?? '').trim();
    _updatedBy.text = (updatedBy ?? '').trim();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(GtinUiConstants.sectionAudit),
        GtinValidatedField(
          controller: _createdBy,
          fieldName: 'created_by',
          label: GtinUiConstants.labelCreatedBy,
          readOnly: widget.isReadOnly,
          maxLength: 64,
          validator: GtinFieldValidators.validateCreatedBy,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _updatedBy,
          fieldName: 'updated_by',
          label: GtinUiConstants.labelUpdatedBy,
          readOnly: widget.isReadOnly,
          maxLength: 64,
          validator: GtinFieldValidators.validateUpdatedBy,
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(GtinUiConstants.sectionAudit),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
    );
  }
}

