import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/pharma_padded_validated_field.dart';

class PharmaStorageHandlingContent extends StatelessWidget {
  const PharmaStorageHandlingContent({
    required this.isEditing,
    required this.storageConditionsController,
    required this.minStorageTempController,
    required this.maxStorageTempController,
    required this.requiresRefrigeration,
    required this.requiresFreezing,
    required this.lightSensitive,
    required this.humiditySensitive,
    required this.coldChainRequired,
    required this.onRequiresRefrigerationChanged,
    required this.onRequiresFreezingChanged,
    required this.onLightSensitiveChanged,
    required this.onHumiditySensitiveChanged,
    super.key,
  });

  final bool isEditing;
  final TextEditingController storageConditionsController;
  final TextEditingController minStorageTempController;
  final TextEditingController maxStorageTempController;
  final bool requiresRefrigeration;
  final bool requiresFreezing;
  final bool lightSensitive;
  final bool humiditySensitive;
  final bool coldChainRequired;
  final ValueChanged<bool> onRequiresRefrigerationChanged;
  final ValueChanged<bool> onRequiresFreezingChanged;
  final ValueChanged<bool> onLightSensitiveChanged;
  final ValueChanged<bool> onHumiditySensitiveChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PharmaPaddedValidatedField(
          controller: storageConditionsController,
          fieldName: 'storageConditions',
          label: 'Storage Conditions',
          helperText: 'Detailed storage instructions',
          maxLines: 2,
          maxLength: 500,
          readOnly: !isEditing,
        ),
        Row(
          children: [
            Expanded(
              child: PharmaPaddedValidatedField(
                controller: minStorageTempController,
                fieldName: 'minStorageTempCelsius',
                label: 'Min Temp (°C)',
                maxLength: 10,
                readOnly: !isEditing,
                validator: (value) => PharmaFieldValidators.validateStorageTemp(
                  value,
                  fieldName: 'min_storage_temp_celsius',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PharmaPaddedValidatedField(
                controller: maxStorageTempController,
                fieldName: 'maxStorageTempCelsius',
                label: 'Max Temp (°C)',
                maxLength: 10,
                readOnly: !isEditing,
                validator: (value) => PharmaFieldValidators.validateStorageTemp(
                  value,
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
              selected: requiresRefrigeration,
              onSelected: isEditing ? onRequiresRefrigerationChanged : null,
            ),
            FilterChip(
              label: const Text('Freezing'),
              selected: requiresFreezing,
              onSelected: isEditing ? onRequiresFreezingChanged : null,
            ),
            FilterChip(
              label: const Text('Light Sensitive'),
              selected: lightSensitive,
              onSelected: isEditing ? onLightSensitiveChanged : null,
            ),
            FilterChip(
              label: const Text('Humidity Sensitive'),
              selected: humiditySensitive,
              onSelected: isEditing ? onHumiditySensitiveChanged : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Cold chain required'),
          subtitle: const Text('Derived from max storage temperature (< 8°C)'),
          value: coldChainRequired,
          onChanged: null,
        ),
      ],
    );
  }
}
