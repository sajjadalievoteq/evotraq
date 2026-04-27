import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class AuditCoreGroup extends StatefulWidget {
  const AuditCoreGroup({
    super.key,
    required this.isReadOnly,
  });

  final bool isReadOnly;

  @override
  State<AuditCoreGroup> createState() => _AuditCoreGroupState();
}

class _AuditCoreGroupState extends State<AuditCoreGroup> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget sectionLabel(String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sectionLabel('9. Audit (Core)'),
        GtinValidatedField(
          controller: _createdBy,
          fieldName: 'created_by',
          label: 'Created By',
          readOnly: widget.isReadOnly,
          maxLength: 64,
          validator: GtinFieldValidators.validateCreatedBy,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _updatedBy,
          fieldName: 'updated_by',
          label: 'Updated By',
          readOnly: widget.isReadOnly,
          maxLength: 64,
          validator: GtinFieldValidators.validateUpdatedBy,
        ),
      ],
    );
  }
}

