import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';
import 'package:traqtrace_app/shared/widgets/gln_selector.dart';

class ObjectEventFormLocationSection extends StatelessWidget {
  final String? businessLocationGLN;
  final String? readPointGLN;
  final bool isViewOnly;
  final bool isBusinessLocationMandatory;
  final bool isReadPointMandatory;
  final ObjectEventFormValidationContext validation;
  final ValueChanged<String?> onBusinessLocationChanged;
  final ValueChanged<String?> onReadPointChanged;

  const ObjectEventFormLocationSection({
    super.key,
    required this.businessLocationGLN,
    required this.readPointGLN,
    required this.isViewOnly,
    required this.isBusinessLocationMandatory,
    required this.isReadPointMandatory,
    required this.validation,
    required this.onBusinessLocationChanged,
    required this.onReadPointChanged,
  });

  GLN? _glnFromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    try {
      return GLN.fromCode(code);
    } catch (_) {
      return null;
    }
  }

  String? _validateGlnField(String fieldName, String? code, bool mandatory) {
    if (mandatory && (code == null || code.isEmpty)) {
      final label = fieldName == 'readPointGLN'
          ? 'Read Point GLN is required for EPCIS 2.0'
          : 'Business Location GLN is required by GS1 standard';
      validation.setFieldError(fieldName, label);
      return label;
    }
    if (code != null && code.isNotEmpty) {
      final error = ObjectEventFormValidators.validateLocationGln(
        code,
        required: mandatory,
      );
      if (error != null) {
        final formatted = fieldName == 'readPointGLN'
            ? 'Invalid GLN format. Expected 13 digits or valid GS1 format.'
            : error;
        validation.setFieldError(fieldName, formatted);
        return formatted;
      }
    }
    validation.setFieldError(fieldName, null);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Location Information (required)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isViewOnly)
            ObjectEventFormReadOnlyText(
              label: 'Business Location GLN',
              value: businessLocationGLN ?? 'Not provided',
            )
          else
            GLNSelector(
              label: 'Business Location GLN',
              hintText:
                  'e.g., 0614141.00001.0 or urn:epc:id:sgln:0614141.00001.0',
              initialValue: _glnFromCode(businessLocationGLN),
              isRequired: isBusinessLocationMandatory,
              errorText: validation.getFieldError('businessLocationGLN'),
              onChanged: (gln) {
                final code = gln?.glnCode;
                onBusinessLocationChanged(code);
                _validateGlnField(
                  'businessLocationGLN',
                  code,
                  isBusinessLocationMandatory,
                );
              },
            ),
          const SizedBox(height: 8.0),
          if (isViewOnly)
            ObjectEventFormReadOnlyText(
              label: 'Read Point GLN',
              value: readPointGLN ?? 'Not provided',
            )
          else
            GLNSelector(
              label: 'Read Point GLN',
              hintText:
                  'e.g., 0614141.00777.0 or urn:epc:id:sgln:0614141.00777.0',
              initialValue: _glnFromCode(readPointGLN),
              isRequired: isReadPointMandatory,
              errorText: validation.getFieldError('readPointGLN'),
              onChanged: (gln) {
                final code = gln?.glnCode;
                onReadPointChanged(code);
                _validateGlnField(
                  'readPointGLN',
                  code,
                  isReadPointMandatory,
                );
              },
            ),
        ],
      ),
    );
  }
}
