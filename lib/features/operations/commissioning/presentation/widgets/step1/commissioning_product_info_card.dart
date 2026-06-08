import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/shared/widgets/gtin_selector.dart';

/// GTIN, batch/lot, and reference fields for commissioning step 1.
class CommissioningProductInfoCard extends StatelessWidget {
  const CommissioningProductInfoCard({
    super.key,
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
            GtinSelector(
              label: 'GTIN',
              hintText: 'Search GTIN code or product name…',
              initialValue: selectedGTIN,
              onChanged: onGtinChanged,
              isRequired: true,
              errorText: gtinError,
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
