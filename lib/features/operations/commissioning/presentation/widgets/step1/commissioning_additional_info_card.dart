import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';

/// Optional ILMD and regulatory fields for commissioning step 1.
class CommissioningAdditionalInfoCard extends StatelessWidget {
  const CommissioningAdditionalInfoCard({
    super.key,
    required this.countryOfOriginController,
    required this.productionOrderController,
    required this.productionLineController,
    required this.regulatoryMarketController,
    required this.regulatoryStatusController,
    required this.operatorIdController,
    required this.notesController,
  });

  final TextEditingController countryOfOriginController;
  final TextEditingController productionOrderController;
  final TextEditingController productionLineController;
  final TextEditingController regulatoryMarketController;
  final TextEditingController regulatoryStatusController;
  final TextEditingController operatorIdController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Additional Information',
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gs1ValidatedField(
            controller: countryOfOriginController,
            fieldName: 'countryOfOrigin',
            label: 'Country of Origin',
            hintText: 'e.g. AE, SA, GB',
            maxLength: 2,
            validator:
                CommissioningFieldValidators.validateCountryOfOriginAlpha2,
          ),
          Gs1ValidatedField(
            controller: productionOrderController,
            fieldName: 'productionOrder',
            label: 'Production Order',
            hintText: 'PO or work-order reference',
            validator:
                CommissioningFieldValidators.validateProductionOrderOptional,
          ),
          const SizedBox(height: 16),
          Gs1ValidatedField(
            controller: productionLineController,
            fieldName: 'productionLine',
            label: 'Production Line',
            hintText: 'Line identifier',
            validator:
                CommissioningFieldValidators.validateProductionLineOptional,
          ),
          const SizedBox(height: 16),
          Gs1ValidatedField(
            controller: regulatoryMarketController,
            fieldName: 'regulatoryMarket',
            label: 'Regulatory Market',
            hintText: 'e.g. UAE, KSA, EU',
            validator:
                CommissioningFieldValidators.validateRegulatoryMarketOptional,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: regulatoryStatusController.text.trim().isEmpty
                ? null
                : regulatoryStatusController.text.trim().toUpperCase(),
            hint: const Text('Not set (optional)'),
            decoration: const InputDecoration(
              labelText: 'Regulatory Status',
              border: OutlineInputBorder(),
              helperText: 'Optional regulatory approval state',
            ),
            items: (CommissioningFieldValidators.regulatoryStatusCodes.toList()
                  ..sort())
                .map((code) => DropdownMenuItem<String>(
                      value: code,
                      child: Text(code),
                    ))
                .toList(),
            onChanged: (v) => regulatoryStatusController.text = v ?? '',
          ),
          const SizedBox(height: 16),
          Gs1ValidatedField(
            controller: operatorIdController,
            fieldName: 'operatorId',
            label: 'Operator ID',
            hintText: 'Enter operator ID',
            validator: CommissioningFieldValidators.validateOperatorIdOptional,
          ),
          const SizedBox(height: 16),
          Gs1ValidatedField(
            controller: notesController,
            fieldName: 'notes',
            label: 'Notes',
            hintText: 'Enter any additional notes',
            maxLines: 3,
            validator: CommissioningFieldValidators.validateNotesOptional,
          ),
        ],
      ),
    );
  }
}
