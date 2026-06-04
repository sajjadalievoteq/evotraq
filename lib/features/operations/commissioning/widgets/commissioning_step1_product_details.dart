import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/shared/widgets/gln_selector.dart';

import '../../../../core/utils/responsive_utils.dart';

/// Step 1 of the commissioning wizard — product info, location, dates and
/// optional ILMD / regulatory fields.
class CommissioningStep1ProductDetails extends StatelessWidget {
  const CommissioningStep1ProductDetails({
    super.key,
    required this.availableGTINs,
    required this.selectedGTIN,
    required this.gtinError,
    required this.isLoadingGTINs,
    required this.gtinController,
    required this.batchLotController,
    required this.referenceController,
    required this.commissioningLocationGLN,
    required this.locationError,
    required this.expiryDate,
    required this.productionDate,
    required this.bestBeforeDate,
    required this.countryOfOriginController,
    required this.productionOrderController,
    required this.productionLineController,
    required this.regulatoryMarketController,
    required this.regulatoryStatusController,
    required this.operatorIdController,
    required this.notesController,
    required this.onGtinChanged,
    required this.onLocationChanged,
    required this.onSelectDate,
    required this.onClearDate,
    this.onScanProductBarcode,
  });

  final List<GTIN> availableGTINs;
  final GTIN? selectedGTIN;
  final String? gtinError;
  final bool isLoadingGTINs;

  final TextEditingController gtinController;
  final TextEditingController batchLotController;
  final TextEditingController referenceController;

  final GLN? commissioningLocationGLN;
  final String? locationError;

  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;

  final TextEditingController countryOfOriginController;
  final TextEditingController productionOrderController;
  final TextEditingController productionLineController;
  final TextEditingController regulatoryMarketController;
  final TextEditingController regulatoryStatusController;
  final TextEditingController operatorIdController;
  final TextEditingController notesController;

  final ValueChanged<GTIN?> onGtinChanged;
  final ValueChanged<GLN?> onLocationChanged;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onClearDate;

  /// Called when the user taps the "Scan Barcode" button on Step 1.
  /// The parent screen opens the scanner and applies the result.
  final VoidCallback? onScanProductBarcode;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      padding: ResponsiveUtils.paddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductInfoCard(
            availableGTINs: availableGTINs,
            selectedGTIN: selectedGTIN,
            gtinError: gtinError,
            isLoadingGTINs: isLoadingGTINs,
            gtinController: gtinController,
            batchLotController: batchLotController,
            referenceController: referenceController,
            onGtinChanged: onGtinChanged,
            onScanProductBarcode: onScanProductBarcode,
          ),
          _LocationCard(
            commissioningLocationGLN: commissioningLocationGLN,
            locationError: locationError,
            onLocationChanged: onLocationChanged,
          ),
          _DatesCard(
            productionDate: productionDate,
            expiryDate: expiryDate,
            bestBeforeDate: bestBeforeDate,
            onSelectDate: onSelectDate,
            onClearDate: onClearDate,
          ),
          _AdditionalInfoTile(
            countryOfOriginController: countryOfOriginController,
            productionOrderController: productionOrderController,
            productionLineController: productionLineController,
            regulatoryMarketController: regulatoryMarketController,
            regulatoryStatusController: regulatoryStatusController,
            operatorIdController: operatorIdController,
            notesController: notesController,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({
    required this.availableGTINs,
    required this.selectedGTIN,
    required this.gtinError,
    required this.isLoadingGTINs,
    required this.gtinController,
    required this.batchLotController,
    required this.referenceController,
    required this.onGtinChanged,
    this.onScanProductBarcode,
  });

  final List<GTIN> availableGTINs;
  final GTIN? selectedGTIN;
  final String? gtinError;
  final bool isLoadingGTINs;
  final TextEditingController gtinController;
  final TextEditingController batchLotController;
  final TextEditingController referenceController;
  final ValueChanged<GTIN?> onGtinChanged;
  final VoidCallback? onScanProductBarcode;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Product Information',
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onScanProductBarcode != null) ...[
            OutlinedButton.icon(
              onPressed: onScanProductBarcode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Product Barcode'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'or enter manually',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (isLoadingGTINs)
            AppShimmer(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppShimmer.defaultBaseColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else if (availableGTINs.isNotEmpty)
            DropdownButtonFormField<GTIN>(
              isExpanded: true,
              value: selectedGTIN,
              decoration: InputDecoration(
                labelText: 'GTIN *',
                hintText: 'Select a GTIN',
                border: const OutlineInputBorder(),
                errorText: gtinError,
              ),
              validator: (_) =>
                  selectedGTIN == null ? 'GTIN is required' : null,
              items: availableGTINs
                  .map((gtin) => DropdownMenuItem(
                        value: gtin,
                        child: Text(
                            '${gtin.gtinCode} - ${gtin.productName ?? 'Unknown'}',overflow: TextOverflow.ellipsis,),
                      ))
                  .toList(),
              onChanged: onGtinChanged,
            )
          else
            Gs1ValidatedField(
              controller: gtinController,
              fieldName: 'gtinCode',
              label: 'GTIN *',
              hintText: 'Enter 14-digit GTIN',
              keyboardType: TextInputType.number,
              maxLength: 14,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: CommissioningFieldValidators.validateGtinRequired,
            ),
          const SizedBox(height: 16),
          Gs1ValidatedField(
            controller: batchLotController,
            fieldName: 'batchLotNumber',
            label: 'Batch/Lot Number *',
            hintText: 'Enter batch or lot number',
            validator:
                CommissioningFieldValidators.validateBatchLotNumberRequired,
          ),
          const SizedBox(height: 16),
          Gs1ValidatedField(
            controller: referenceController,
            fieldName: 'commissioningReference',
            label: 'Commissioning Reference',
            hintText: 'Enter reference (optional)',
            validator: CommissioningFieldValidators
                .validateCommissioningReferenceOptional,
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.commissioningLocationGLN,
    required this.locationError,
    required this.onLocationChanged,
  });

  final GLN? commissioningLocationGLN;
  final String? locationError;
  final ValueChanged<GLN?> onLocationChanged;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Commissioning Location',
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: GLNSelector(
        label: 'Location GLN *',
        initialValue: commissioningLocationGLN,
        onChanged: onLocationChanged,
        hintText: 'Select commissioning location',
        errorText: locationError,
      ),
    );
  }
}

class _DatesCard extends StatelessWidget {
  const _DatesCard({
    required this.productionDate,
    required this.expiryDate,
    required this.bestBeforeDate,
    required this.onSelectDate,
    required this.onClearDate,
  });

  final DateTime? productionDate;
  final DateTime? expiryDate;
  final DateTime? bestBeforeDate;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onClearDate;

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Dates',
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        children: [
          _DateRow(
            icon: Icons.calendar_today,
            label: 'Production Date',
            dateKey: 'production',
            date: productionDate,
            onSelect: onSelectDate,
            onClear: onClearDate,
            formatDate: _formatDate,
          ),
          const Divider(),
          _DateRow(
            icon: Icons.event,
            label: 'Expiry Date *',
            dateKey: 'expiry',
            date: expiryDate,
            onSelect: onSelectDate,
            onClear: onClearDate,
            formatDate: _formatDate,
          ),
          const Divider(),
          _DateRow(
            icon: Icons.schedule,
            label: 'Best Before Date',
            dateKey: 'bestBefore',
            date: bestBeforeDate,
            onSelect: onSelectDate,
            onClear: onClearDate,
            formatDate: _formatDate,
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.icon,
    required this.label,
    required this.dateKey,
    required this.date,
    required this.onSelect,
    required this.onClear,
    required this.formatDate,
  });

  final IconData icon;
  final String label;
  final String dateKey;
  final DateTime? date;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onClear;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(date != null ? formatDate(date!) : 'Not set'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => onSelect(dateKey),
          ),
          if (date != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => onClear(dateKey),
            ),
        ],
      ),
    );
  }
}

class _AdditionalInfoTile extends StatelessWidget {
  const _AdditionalInfoTile({
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
