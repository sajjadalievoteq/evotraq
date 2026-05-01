import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_detail_form_types.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class GlnContactCoreGroup extends StatelessWidget {
  const GlnContactCoreGroup({
    super.key,
    required this.setFieldError,
    required this.readOnly,
    required this.contactNameController,
    required this.contactEmailController,
    required this.contactPhoneController,
  });

  final GlnFormSetFieldError setFieldError;
  final bool readOnly;
  final TextEditingController contactNameController;
  final TextEditingController contactEmailController;
  final TextEditingController contactPhoneController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Contact'),
        GtinValidatedField(
          controller: contactNameController,
          fieldName: 'contactName',
          label: 'Contact name',
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
                label: 'Email',
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
                label: 'Phone',
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
  }
}
