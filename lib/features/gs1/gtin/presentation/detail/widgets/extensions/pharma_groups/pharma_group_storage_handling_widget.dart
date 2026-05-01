import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class StorageHandlingGroupWidget extends StatefulWidget {
  const StorageHandlingGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialStorageConditions,
    required this.initialMinStorageTemp,
    required this.initialMaxStorageTemp,
    required this.initialRequiresRefrigeration,
    required this.initialRequiresFreezing,
    required this.initialLightSensitive,
    required this.initialHumiditySensitive,
    required this.initialColdChainRequired,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialStorageConditions;
  final String initialMinStorageTemp;
  final String initialMaxStorageTemp;
  final bool initialRequiresRefrigeration;
  final bool initialRequiresFreezing;
  final bool initialLightSensitive;
  final bool initialHumiditySensitive;
  final bool initialColdChainRequired;
  final bool showFieldSkeleton;
  final void Function({
    required String storageConditions,
    required String minStorageTemp,
    required String maxStorageTemp,
    required bool requiresRefrigeration,
    required bool requiresFreezing,
    required bool lightSensitive,
    required bool humiditySensitive,
    required bool coldChainRequired,
  }) onChanged;

  @override
  State<StorageHandlingGroupWidget> createState() => _StorageHandlingGroupWidgetState();
}

class _StorageHandlingGroupWidgetState extends State<StorageHandlingGroupWidget> {
  late final TextEditingController _storageConditionsController;
  late final TextEditingController _minStorageTempController;
  late final TextEditingController _maxStorageTempController;
  late bool _requiresRefrigeration;
  late bool _requiresFreezing;
  late bool _lightSensitive;
  late bool _humiditySensitive;

  @override
  void initState() {
    super.initState();
    _storageConditionsController =
        TextEditingController(text: widget.initialStorageConditions);
    _minStorageTempController = TextEditingController(text: widget.initialMinStorageTemp);
    _maxStorageTempController = TextEditingController(text: widget.initialMaxStorageTemp);
    _requiresRefrigeration = widget.initialRequiresRefrigeration;
    _requiresFreezing = widget.initialRequiresFreezing;
    _lightSensitive = widget.initialLightSensitive;
    _humiditySensitive = widget.initialHumiditySensitive;

    _storageConditionsController.addListener(_emitChange);
    _minStorageTempController.addListener(_emitChange);
    _maxStorageTempController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant StorageHandlingGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStorageConditions != oldWidget.initialStorageConditions &&
        widget.initialStorageConditions != _storageConditionsController.text) {
      _storageConditionsController.text = widget.initialStorageConditions;
    }
    if (widget.initialMinStorageTemp != oldWidget.initialMinStorageTemp &&
        widget.initialMinStorageTemp != _minStorageTempController.text) {
      _minStorageTempController.text = widget.initialMinStorageTemp;
    }
    if (widget.initialMaxStorageTemp != oldWidget.initialMaxStorageTemp &&
        widget.initialMaxStorageTemp != _maxStorageTempController.text) {
      _maxStorageTempController.text = widget.initialMaxStorageTemp;
    }
    _requiresRefrigeration = widget.initialRequiresRefrigeration;
    _requiresFreezing = widget.initialRequiresFreezing;
    _lightSensitive = widget.initialLightSensitive;
    _humiditySensitive = widget.initialHumiditySensitive;
  }

  @override
  void dispose() {
    _storageConditionsController.dispose();
    _minStorageTempController.dispose();
    _maxStorageTempController.dispose();
    super.dispose();
  }

  bool get _coldChainRequired {
    final max = double.tryParse(_maxStorageTempController.text.trim());
    return max != null && max < 8;
  }

  void _emitChange() {
    widget.onChanged(
      storageConditions: _storageConditionsController.text,
      minStorageTemp: _minStorageTempController.text,
      maxStorageTemp: _maxStorageTempController.text,
      requiresRefrigeration: _requiresRefrigeration,
      requiresFreezing: _requiresFreezing,
      lightSensitive: _lightSensitive,
      humiditySensitive: _humiditySensitive,
      coldChainRequired: _coldChainRequired,
    );
  }

  Widget _field(
    TextEditingController controller,
    String fieldName,
    String label, {
    String? helperText,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: GtinValidatedField(
        controller: controller,
        fieldName: fieldName,
        label: label,
        helperText: helperText,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: maxLength != null ? [LengthLimitingTextInputFormatter(maxLength)] : null,
        readOnly: !widget.isEditing,
        validator: validator,
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(
          'Storage & handling',
          padding: EdgeInsets.only(bottom: 12),
        ),
        _field(
          _storageConditionsController,
          'storageConditions',
          'Storage Conditions',
          helperText: 'Detailed storage instructions',
          maxLines: 2,
          maxLength: 500,
        ),
        Row(
          children: [
            Expanded(
              child: _field(
                _minStorageTempController,
                'minStorageTempCelsius',
                'Min Temp (°C)',
                maxLength: 10,
                validator: (v) => PharmaFieldValidators.validateStorageTemp(
                  v,
                  fieldName: 'min_storage_temp_celsius',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _field(
                _maxStorageTempController,
                'maxStorageTempCelsius',
                'Max Temp (°C)',
                maxLength: 10,
                validator: (v) => PharmaFieldValidators.validateStorageTemp(
                  v,
                  fieldName: 'max_storage_temp_celsius',
                ),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 16,
          children: [
            FilterChip(
              label: const Text('Refrigeration'),
              selected: _requiresRefrigeration,
              onSelected: widget.isEditing
                  ? (v) {
                      setState(() => _requiresRefrigeration = v);
                      _emitChange();
                    }
                  : null,
            ),
            FilterChip(
              label: const Text('Freezing'),
              selected: _requiresFreezing,
              onSelected: widget.isEditing
                  ? (v) {
                      setState(() => _requiresFreezing = v);
                      _emitChange();
                    }
                  : null,
            ),
            FilterChip(
              label: const Text('Light Sensitive'),
              selected: _lightSensitive,
              onSelected: widget.isEditing
                  ? (v) {
                      setState(() => _lightSensitive = v);
                      _emitChange();
                    }
                  : null,
            ),
            FilterChip(
              label: const Text('Humidity Sensitive'),
              selected: _humiditySensitive,
              onSelected: widget.isEditing
                  ? (v) {
                      setState(() => _humiditySensitive = v);
                      _emitChange();
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Cold chain required'),
          subtitle: const Text('Derived from max storage temperature (< 8°C)'),
          value: _coldChainRequired,
          onChanged: null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: _content(),
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: outline.withOpacity(0.45)),
      ),
      child: GtinFieldSkeletonMask(
        show: widget.showFieldSkeleton,
        child: content,
        skeletonBuilder: (c) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel(
                'Storage & handling',
                padding: EdgeInsets.only(bottom: 12),
              ),
              GtinSkeletonOutlineField(color: c, height: 56),
              const SizedBox(height: 8),
              GtinSkeletonOutlineField(color: c, height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
