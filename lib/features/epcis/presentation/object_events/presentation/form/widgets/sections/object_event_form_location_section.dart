import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';

class ObjectEventFormLocationSection extends StatelessWidget {
  final GLN? businessLocation;
  final GLN? readPoint;
  final bool isViewOnly;
  final bool isBusinessLocationMandatory;
  final bool isReadPointMandatory;
  final ObjectEventFormValidationContext validation;
  final ValueChanged<GLN?> onBusinessLocationChanged;
  final ValueChanged<GLN?> onReadPointChanged;

  const ObjectEventFormLocationSection({
    super.key,
    required this.businessLocation,
    required this.readPoint,
    required this.isViewOnly,
    required this.isBusinessLocationMandatory,
    required this.isReadPointMandatory,
    required this.validation,
    required this.onBusinessLocationChanged,
    required this.onReadPointChanged,
  });

  String _formatGlnDisplay(GLN? gln) {
    if (gln == null) return 'Not provided';
    if (gln.locationName.isNotEmpty && !isPlaceholderGlnLocation(gln)) {
      return '${gln.glnCode} - ${gln.locationName}';
    }
    return gln.glnCode;
  }

  String? _validateGlnField(String fieldName, String? code, bool mandatory) {
    if (mandatory && (code == null || code.isEmpty)) {
      final label = fieldName == 'readPointGLN'
          ? 'Read Point GLN is required'
          : 'Business Location GLN is required';
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
      title: 'Location Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isViewOnly)
            ObjectEventFormReadOnlyText(
              label: 'Business Location GLN',
              value: _formatGlnDisplay(businessLocation),
            )
          else
            GLNSelector(
              label: 'Business Location GLN',
              hintText:
                  'e.g., 0614141.00001.0 or urn:epc:id:sgln:0614141.00001.0',
              initialValue: businessLocation,
              isRequired: isBusinessLocationMandatory,
              errorText: validation.getFieldError('businessLocationGLN'),
              onChanged: (gln) {
                onBusinessLocationChanged(gln);
                _validateGlnField(
                  'businessLocationGLN',
                  gln?.glnCode,
                  isBusinessLocationMandatory,
                );
              },
            ),
          const SizedBox(height: 8.0),
          if (isViewOnly)
            ObjectEventFormReadOnlyText(
              label: 'Read Point GLN',
              value: _formatGlnDisplay(readPoint),
            )
          else
            GLNSelector(
              label: 'Read Point GLN',
              hintText:
                  'e.g., 0614141.00777.0 or urn:epc:id:sgln:0614141.00777.0',
              initialValue: readPoint,
              isRequired: isReadPointMandatory,
              errorText: validation.getFieldError('readPointGLN'),
              onChanged: (gln) {
                onReadPointChanged(gln);
                _validateGlnField(
                  'readPointGLN',
                  gln?.glnCode,
                  isReadPointMandatory,
                );
              },
            ),
        ],
      ),
    );
  }
}
