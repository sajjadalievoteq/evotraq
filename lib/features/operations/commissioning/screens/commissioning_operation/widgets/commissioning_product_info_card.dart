import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gtin_selector.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_status_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

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
    required this.onBatchLotEditingComplete,
    required this.onBatchLotFocusLost,
    this.onScanProductBarcode,
    this.showPharmaBatchLookup = false,
    this.batchLookupStatus = CommissioningBatchLookupStatus.idle,
    this.resolvedBatch,
    this.batchLookupError,
    this.registrationPanelExpanded = false,
    this.registrationExpiryDate,
    this.registrationManufactureDate,
    required this.registrationQuantityController,
    required this.onSelectRegistrationDate,
    required this.onClearRegistrationDate,
    required this.onRegisterBatch,
    required this.onToggleRegistrationPanel,
    this.isBatchRegistering = false,
  });

  final List<GTIN> availableGTINs;
  final GTIN? selectedGTIN;
  final String? gtinError;
  final bool isLoadingGTINs;
  final TextEditingController gtinController;
  final ValueChanged<GTIN?> onGtinChanged;
  final TextEditingController batchLotController;
  final TextEditingController referenceController;
  final VoidCallback onBatchLotEditingComplete;
  final VoidCallback onBatchLotFocusLost;
  final VoidCallback? onScanProductBarcode;

  final bool showPharmaBatchLookup;
  final CommissioningBatchLookupStatus batchLookupStatus;
  final GtinBatch? resolvedBatch;
  final String? batchLookupError;
  final bool registrationPanelExpanded;
  final DateTime? registrationExpiryDate;
  final DateTime? registrationManufactureDate;
  final TextEditingController registrationQuantityController;
  final ValueChanged<String> onSelectRegistrationDate;
  final ValueChanged<String> onClearRegistrationDate;
  final VoidCallback onRegisterBatch;
  final ValueChanged<bool> onToggleRegistrationPanel;
  final bool isBatchRegistering;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final batchLot = batchLotController.text.trim();

    return Gs1GroupCard(
      title: 'Product Information',
      showRequiredStar: true,
      outlineColor: theme.colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onScanProductBarcode != null) ...[
            OutlinedButton.icon(
              onPressed: onScanProductBarcode,
              icon: TraqIcon(AppAssets.iconQr),
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
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
          else
            GtinSelector(
              label: 'GTIN',
              hintText: 'Search GTIN code or product name…',
              initialValue: selectedGTIN,
              initialGtins: availableGTINs,
              onChanged: onGtinChanged,
              isRequired: true,
              errorText: gtinError,
            ),
          const SizedBox(height: 16),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) onBatchLotFocusLost();
            },
            child: Gs1ValidatedField(
              controller: batchLotController,
              fieldName: 'batchLotNumber',
              label: 'Batch/Lot Number *',
              hintText: 'Enter batch or lot number',
              validator:
                  CommissioningFieldValidators.validateBatchLotNumberRequired,
              onEditingComplete: onBatchLotEditingComplete,
            ),
          ),
          if (showPharmaBatchLookup && batchLot.isNotEmpty) ...[
            const SizedBox(height: 12),
            CommissioningBatchStatusCard(
              status: batchLookupStatus,
              batchLot: batchLot,
              resolvedBatch: resolvedBatch,
              errorMessage: batchLookupError,
              registrationPanelExpanded: registrationPanelExpanded,
              registrationExpiryDate: registrationExpiryDate,
              registrationManufactureDate: registrationManufactureDate,
              registrationQuantityController: registrationQuantityController,
              onSelectRegistrationDate: onSelectRegistrationDate,
              onClearRegistrationDate: onClearRegistrationDate,
              onRegisterBatch: onRegisterBatch,
              onToggleRegistrationPanel: onToggleRegistrationPanel,
              isRegistering: isBatchRegistering,
            ),
          ],
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
