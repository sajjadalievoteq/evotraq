import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/constants/gtin_detail_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_date_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_structure_chips.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';

/// Core GTIN master-data form: identity, product, packaging, status, dates, and footer button.
/// Industry extensions are supplied via [industrySection].
class GtinDetailForm extends StatelessWidget {
  const GtinDetailForm({
    super.key,
    required this.formKey,
    required this.isReadOnly,
    required this.gtinFieldLocked,
    required this.gtinFocusNode,
    required this.onGtinEditingComplete,
    required this.gtinCodeController,
    required this.productNameController,
    required this.manufacturerController,
    required this.packagingLevelController,
    required this.onPackagingLevelChanged,
    required this.packSizeController,
    required this.status,
    required this.onStatusChanged,
    required this.registrationNumberController,
    required this.registrationDateController,
    required this.expirationDateController,
    required this.onPickRegistrationDate,
    required this.onPickExpirationDate,
    this.unboundSpecSection,
    required this.industrySection,
    required this.showSubmitButton,
    required this.isSubmitting,
    required this.onSubmit,
    required this.submitButtonTitle,
  });

  final GlobalKey<FormState> formKey;
  final bool isReadOnly;
  final bool gtinFieldLocked;
  final FocusNode gtinFocusNode;
  final VoidCallback onGtinEditingComplete;
  final TextEditingController gtinCodeController;
  final TextEditingController productNameController;
  final TextEditingController manufacturerController;
  final TextEditingController packagingLevelController;
  final ValueChanged<String?> onPackagingLevelChanged;
  final TextEditingController packSizeController;
  final String? status;
  final ValueChanged<String?> onStatusChanged;
  final TextEditingController registrationNumberController;
  final TextEditingController registrationDateController;
  final TextEditingController expirationDateController;
  final Future<void> Function() onPickRegistrationDate;
  final Future<void> Function() onPickExpirationDate;
  /// Local-only GDSN-style fields; not bound to create/update API.
  final Widget? unboundSpecSection;
  final Widget industrySection;
  final bool showSubmitButton;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String submitButtonTitle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(

      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Constants.spacing),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GtinValidatedField(
                  focusNode: gtinFocusNode,
                  onEditingComplete: onGtinEditingComplete,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                  controller: gtinCodeController,
                  fieldName: 'gtinCode',
                  label: 'GTIN Code *',
                  helperText:
                      '8, 12, 13, or 14 digits; GS1 check digit. Spaces and hyphens are ignored.',
                  readOnly: gtinFieldLocked,
                  validator: GtinFieldValidators.validateGtinCode,
                ),
                GtinStructureChips(gtinCodeController: gtinCodeController),
              ],
            ),
            const SizedBox(height: 16),
            GtinValidatedField(
              controller: productNameController,
              fieldName: 'productName',
              label: 'Product Name *',
              readOnly: isReadOnly,
              validator: GtinFieldValidators.productNameRequired,
            ),
            const SizedBox(height: 16),
            GtinValidatedField(
              controller: manufacturerController,
              fieldName: 'manufacturer',
              label: 'Manufacturer *',
              readOnly: isReadOnly,
              validator: GtinFieldValidators.manufacturerRequired,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: packagingLevelController.text.isEmpty
                  ? null
                  : packagingLevelController.text,
              decoration: const InputDecoration(
                labelText: 'Packaging Level',
              ),
              items: GtinDetailConstants.packagingLevelOptions
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    ),
                  )
                  .toList(),
              onChanged: isReadOnly
                  ? null
                  : (value) => onPackagingLevelChanged(value),
            ),
            const SizedBox(height: 16),
            GtinValidatedField(
              controller: packSizeController,
              fieldName: 'packSize',
              label: 'Pack Size',
              helperText: 'e.g., 30, 100, 500',
              readOnly: isReadOnly,
              validator: GtinFieldValidators.packSizeOptionalInt,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: GtinDetailConstants.statusOptions
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    ),
                  )
                  .toList(),
              onChanged: isReadOnly ? null : (value) => onStatusChanged(value),
            ),
            const SizedBox(height: 16),
            GtinValidatedField(
              controller: registrationNumberController,
              fieldName: 'registrationNumber',
              label: 'Registration Number',
              helperText: 'Market authorization or registration number',
              readOnly: isReadOnly,
              validator: (value) => null,
            ),
            const SizedBox(height: 16),
            GtinDateField(
              controller: registrationDateController,
              label: 'Registration Date',
              enabled: !isReadOnly,
              onPick: onPickRegistrationDate,
            ),
            const SizedBox(height: 16),
            GtinDateField(
              controller: expirationDateController,
              label: 'Expiration Date',
              enabled: !isReadOnly,
              onPick: onPickExpirationDate,
            ),
            if (unboundSpecSection != null) ...[
              const SizedBox(height: 24),
              unboundSpecSection!,
            ],
            const SizedBox(height: 32),
            industrySection,
            const SizedBox(height: 32),
            if (showSubmitButton)
              CustomButtonWidget(
                onTap: isSubmitting ? null : onSubmit,
                title: submitButtonTitle,
              ),
          ],
        ),
      ),
    );
  }
}
