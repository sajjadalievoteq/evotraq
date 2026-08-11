import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_cbv_field_skeleton.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_form_field_decoration.dart';

class ObjectEventCbvDispositionDropdown extends StatelessWidget {
  const ObjectEventCbvDispositionDropdown({
    required this.items,
    required this.selectedValue,
    required this.epcisVersion,
    required this.isMandatory,
    required this.validation,
    required this.isLoading,
    required this.disabled,
    required this.onChanged,
    required this.onDefaultSelected,
    super.key,
  });

  final List<CbvVocabularyItem> items;
  final String? selectedValue;
  final EPCISVersion epcisVersion;
  final bool isMandatory;
  final ObjectEventFormValidationContext validation;
  final bool isLoading;
  final bool disabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onDefaultSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const ObjectEventCbvFieldSkeleton();
    if (!disabled && items.isEmpty) {
      return const Text(
        'No disposition options for the selected business step.',
        style: TextStyle(color: Colors.grey),
      );
    }

    final selectable = items.map((item) => _format(item.urn)).toList();
    final dropdownValue = selectable.contains(selectedValue)
        ? selectedValue
        : selectable.firstOrNull;
    if (dropdownValue != null && dropdownValue != selectedValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onDefaultSelected(dropdownValue);
      });
    }

    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
        context: context,
        fieldName: 'disposition',
        label: 'Disposition',
        hintText: 'Select a disposition',
        isMandatory: isMandatory,
        validation: validation,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: _format(item.urn),
          child: Text(item.label),
        );
      }).toList(),
      validator: (value) {
        final error = ObjectEventFormValidators.validateDispositionCbv(value);
        validation.setFieldError('disposition', error);
        return error;
      },
      onChanged: disabled
          ? null
          : (value) {
              if (value != null) onChanged(value);
            },
    );
  }

  String _format(String urn) {
    final version = epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';
    return CbvVocabularyFormatter.formatDisposition(version, urn);
  }
}
