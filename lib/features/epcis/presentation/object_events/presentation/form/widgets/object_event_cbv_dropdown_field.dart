import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_field_decoration.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_required_indicator.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';

enum ObjectEventCbvFieldType { businessStep, disposition }

class ObjectEventCbvDropdownField extends StatefulWidget {
  final ObjectEventCbvFieldType fieldType;
  final String fieldName;
  final String label;
  final String? value;
  final List<String> standardValues;
  final Map<String, String> valueLabels;
  final bool isMandatory;
  final bool isViewOnly;
  final ObjectEventFormValidationContext validation;
  final EPCISVersion epcisVersion;
  final ValueChanged<String?> onChanged;

  const ObjectEventCbvDropdownField({
    super.key,
    required this.fieldType,
    required this.fieldName,
    required this.label,
    required this.value,
    required this.standardValues,
    this.valueLabels = const {},
    required this.isMandatory,
    required this.isViewOnly,
    required this.validation,
    required this.epcisVersion,
    required this.onChanged,
  });

  @override
  State<ObjectEventCbvDropdownField> createState() =>
      _ObjectEventCbvDropdownFieldState();
}

class _ObjectEventCbvDropdownFieldState extends State<ObjectEventCbvDropdownField> {
  bool _useCustomValue = false;

  @override
  void initState() {
    super.initState();
    _useCustomValue = _isCustomValue(widget.value);
  }

  @override
  void didUpdateWidget(ObjectEventCbvDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_useCustomValue) {
      _useCustomValue = _isCustomValue(widget.value);
    }
  }

  bool _isCustomValue(String? value) {
    if (value == null || value.isEmpty) return false;
    return !widget.standardValues.contains(value);
  }

  String get _cbvPrefix => widget.fieldType == ObjectEventCbvFieldType.businessStep
      ? CbvVocabularyFormatter.bizStepCbvPrefix(_versionString)
      : CbvVocabularyFormatter.dispCbvPrefix(_versionString);

  String get _versionString =>
      widget.epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';

  String get _customHint =>
      '$_cbvPrefix${widget.fieldType == ObjectEventCbvFieldType.businessStep ? 'custom_step' : 'custom_disposition'}';

  String? Function(String?) get _validator =>
      widget.fieldType == ObjectEventCbvFieldType.businessStep
      ? (v) => ObjectEventFormValidators.validateBusinessStepCbv(
          v,
          epcisVersion: widget.epcisVersion,
        )
      : ObjectEventFormValidators.validateDispositionCbv;

  String? Function(String) get _customValidator =>
      widget.fieldType == ObjectEventCbvFieldType.businessStep
      ? (v) => ObjectEventFormValidators.validateCustomBusinessStep(
          v,
          epcisVersion: widget.epcisVersion,
        )
      : (v) => ObjectEventFormValidators.validateCustomDisposition(
          v,
          epcisVersion: widget.epcisVersion,
        );

  @override
  Widget build(BuildContext context) {
    if (widget.isViewOnly) {
      final display = widget.value != null
          ? (widget.valueLabels[widget.value!] ??
              CbvVocabularyFormatter.shortName(widget.value!))
          : null;
      return ObjectEventFormReadOnlyText(
        label: widget.label,
        value: display ?? widget.value,
      );
    }

    final dropdownValue =
        _useCustomValue || _isCustomValue(widget.value) ? null : widget.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
            context: context,
            fieldName: widget.fieldName,
            label: widget.label,
            hintText: 'Select a ${widget.label.toLowerCase()}',
            isMandatory: widget.isMandatory,
            validation: widget.validation,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Custom...')),
            ...widget.standardValues.map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  widget.valueLabels[item] ??
                      CbvVocabularyFormatter.shortName(item),
                ),
              ),
            ),
          ],
          validator: (v) {
            if (_useCustomValue || _isCustomValue(widget.value)) {
              return null;
            }
            final error = _validator(v);
            widget.validation.setFieldError(widget.fieldName, error);
            return error;
          },
          onChanged: (selected) {
            if (selected == null) {
              setState(() => _useCustomValue = true);
              widget.onChanged('');
              return;
            }
            setState(() => _useCustomValue = false);
            widget.onChanged(selected);
            widget.validation.markFieldAsValid(widget.fieldName);
          },
        ),
        if (_useCustomValue || _isCustomValue(widget.value)) ...[
          const SizedBox(height: 8.0),
          TextFormField(
            key: ValueKey('${widget.fieldName}-custom'),
            initialValue: widget.value ?? '',
            decoration: InputDecoration(
              label: objectEventFormFieldLabel(
                context,
                'Custom ${widget.label}',
                widget.isMandatory,
              ),
              hintText: _customHint,
              border: const OutlineInputBorder(),
              errorText: widget.validation.getFieldError(widget.fieldName),
            ),
            validator: (value) {
              final error = _customValidator(value ?? '');
              widget.validation.setFieldError(widget.fieldName, error);
              return error;
            },
            onChanged: (value) {
              widget.onChanged(value.isEmpty ? null : value);
              widget.validation.validateField(
                widget.fieldName,
                value,
                _customValidator,
              );
            },
          ),
        ],
      ],
    );
  }
}
