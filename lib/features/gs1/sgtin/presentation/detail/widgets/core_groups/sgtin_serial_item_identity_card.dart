import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/serial_entry_field.dart';
import 'package:traqtrace_app/core/widgets/gtin_selector.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart' as gtin_model;
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';

class SgtinSerialItemIdentityCard extends StatelessWidget {
  const SgtinSerialItemIdentityCard({
    super.key,
    required this.borderColor,
    required this.isEditing,
    required this.isCreating,
    required this.gtinController,
    required this.serialNumberController,
    required this.batchLotNumberController,
    required this.onGtinChanged,
    required this.setFieldError,
    this.selectedGtin,
  });

  final Color borderColor;
  final bool isEditing;
  final bool isCreating;
  final TextEditingController gtinController;
  final TextEditingController serialNumberController;
  final TextEditingController batchLotNumberController;
  final ValueChanged<gtin_model.GTIN?> onGtinChanged;
  final void Function(String, String?) setFieldError;
  final gtin_model.GTIN? selectedGtin;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Serial Item Identity',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GtinSelector(
            label: 'GTIN',
            initialValue: selectedGtin,
            initialGtinCode:
                gtinController.text.isNotEmpty ? gtinController.text : null,
            onChanged: onGtinChanged,
            isRequired: true,
            readOnly: !(isEditing && isCreating),
          ),
          const SizedBox(height: 12),
          SerialEntryField(
            controller: serialNumberController,
            fieldName: 'serialNumber',
            label: 'Serial Number *',
            enabled: isEditing && isCreating,
            validator: sgtin_validators.validateSerialNumber,
            setFieldError: setFieldError,
          ),
          const SizedBox(height: 12),
          Gs1ValidatedField(
            controller: batchLotNumberController,
            fieldName: 'batchLotNumber',
            label: 'Batch / Lot Number',
            readOnly: !isCreating,
            validator: sgtin_validators.validateBatchLotNumber,
            setFieldError: setFieldError,
          ),
        ],
      ),
    );
  }
}
