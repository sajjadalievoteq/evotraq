import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_detail_form_types.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class GlnDigitalLocationCoreGroup extends StatelessWidget {
  const GlnDigitalLocationCoreGroup({
    super.key,
    required this.setFieldError,
    required this.readOnly,
    required this.digitalAddressType,
    required this.onDigitalAddressTypeChanged,
    required this.digitalAddressValueController,
  });

  final GlnFormSetFieldError setFieldError;
  final bool readOnly;
  final String digitalAddressType;
  final ValueChanged<String?> onDigitalAddressTypeChanged;
  final TextEditingController digitalAddressValueController;

  @override
  Widget build(BuildContext context) {
    final isEditing = !readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Digital location'),
        DropdownButtonFormField<String>(
          value: digitalAddressType,
          decoration: const InputDecoration(
            labelText: 'Digital address type',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'EDI_GATEWAY',
              child: Text('EDI gateway'),
            ),
            DropdownMenuItem(value: 'URL', child: Text('URL')),
            DropdownMenuItem(
              value: 'AS2_ENDPOINT',
              child: Text('AS2 endpoint'),
            ),
            DropdownMenuItem(value: 'SFTP', child: Text('SFTP')),
            DropdownMenuItem(value: 'API', child: Text('API')),
            DropdownMenuItem(value: 'EMAIL', child: Text('Email')),
            DropdownMenuItem(value: 'OTHER', child: Text('Other')),
          ],
          onChanged: isEditing ? onDigitalAddressTypeChanged : null,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: digitalAddressValueController,
          fieldName: 'digitalAddressValue',
          label: 'Digital address value',
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateDigitalAddressValueOptional,
        ),
      ],
    );
  }
}
