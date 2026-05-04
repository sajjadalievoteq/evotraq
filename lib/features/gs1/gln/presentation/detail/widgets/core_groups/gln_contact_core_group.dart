import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class GlnContactCoreGroup extends StatelessWidget {
  const GlnContactCoreGroup({
    super.key,
    this.showFieldSkeleton = false,
    required this.setFieldError,
    required this.readOnly,
    required this.contactNameController,
    required this.contactEmailController,
    required this.contactPhoneController,
  });

  final bool showFieldSkeleton;
  final GlnFormSetFieldError setFieldError;
  final bool readOnly;
  final TextEditingController contactNameController;
  final TextEditingController contactEmailController;
  final TextEditingController contactPhoneController;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(GlnUiConstants.sectionContact),
        GtinValidatedField(
          controller: contactNameController,
          fieldName: 'contactName',
          label: GlnUiConstants.labelContactName,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateContactNameOptional,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GtinValidatedField(
                controller: contactEmailController,
                fieldName: 'contactEmail',
                label: GlnUiConstants.labelEmail,
                readOnly: readOnly,
                setFieldError: setFieldError,
                keyboardType: TextInputType.emailAddress,
                validator: GlnFieldValidators.validateEmailOptional,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: contactPhoneController,
                fieldName: 'contactPhone',
                label: GlnUiConstants.labelPhone,
                readOnly: readOnly,
                setFieldError: setFieldError,
                keyboardType: TextInputType.phone,
                validator: GlnFieldValidators.validateContactPhoneOptional,
              ),
            ),
          ],
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(GlnUiConstants.sectionContact),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
              const SizedBox(width: 12),
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
            ],
          ),
        ],
      ),
    );
  }
}
