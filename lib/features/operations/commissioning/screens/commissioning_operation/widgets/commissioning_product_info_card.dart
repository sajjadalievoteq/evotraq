import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_status_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_identify_epc_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';

class CommissioningProductInfoCard extends StatelessWidget {
  const CommissioningProductInfoCard({
    super.key,
    required this.onEpcResolved,
    required this.batchLotController,
    required this.referenceController,
    required this.onBatchLotEditingComplete,
    required this.onBatchLotFocusLost,
    required this.registrationQuantityController,
    required this.onSelectRegistrationDate,
    required this.onClearRegistrationDate,
    required this.onRegisterBatch,
    required this.onToggleRegistrationPanel,
    this.resolvedParsed,
    this.sourceStatus,
    this.targetStatus,
    this.parseError,
    this.gtinMismatchMessage,
    this.guessabilityWarning,
    this.isResolvingEpc = false,
    this.manualFallbackEnabled = false,
    this.onManualFallbackToggled,
    this.onParseFallback,
    this.showPharmaBatchLookup = false,
    this.batchLookupStatus = CommissioningBatchLookupStatus.idle,
    this.resolvedBatch,
    this.batchLookupError,
    this.registrationPanelExpanded = false,
    this.registrationExpiryDate,
    this.registrationManufactureDate,
    this.isBatchRegistering = false,
  });

  final void Function(EPCParseResult result, {required bool isManual}) onEpcResolved;
  final TextEditingController batchLotController;
  final TextEditingController referenceController;
  final VoidCallback onBatchLotEditingComplete;
  final VoidCallback onBatchLotFocusLost;
  final TextEditingController registrationQuantityController;
  final ValueChanged<String> onSelectRegistrationDate;
  final ValueChanged<String> onClearRegistrationDate;
  final VoidCallback onRegisterBatch;
  final ValueChanged<bool> onToggleRegistrationPanel;

  final EPCParseResult? resolvedParsed;
  final String? sourceStatus;
  final String? targetStatus;
  final String? parseError;
  final String? gtinMismatchMessage;
  final String? guessabilityWarning;
  final bool isResolvingEpc;
  final bool manualFallbackEnabled;
  final ValueChanged<bool>? onManualFallbackToggled;
  final Future<EPCParseResult?> Function(String input)? onParseFallback;

  final bool showPharmaBatchLookup;
  final CommissioningBatchLookupStatus batchLookupStatus;
  final GtinBatch? resolvedBatch;
  final String? batchLookupError;
  final bool registrationPanelExpanded;
  final DateTime? registrationExpiryDate;
  final DateTime? registrationManufactureDate;
  final bool isBatchRegistering;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final batchLot = batchLotController.text.trim();
    final isSgtin = resolvedParsed?.type == EPCType.sgtin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommissioningIdentifyEpcCard(
          onEpcResolved: onEpcResolved,
          resolvedParsed: resolvedParsed,
          sourceStatus: sourceStatus,
          targetStatus: targetStatus,
          parseError: parseError,
          gtinMismatchMessage: gtinMismatchMessage,
          guessabilityWarning: guessabilityWarning,
          isResolving: isResolvingEpc,
          manualFallbackEnabled: manualFallbackEnabled,
          onManualFallbackToggled: onManualFallbackToggled,
          onParseFallback: onParseFallback,
        ),
        const SizedBox(height: 16),
        Gs1GroupCard(
          title: isSgtin ? 'Batch & Reference' : 'Reference',
          showRequiredStar: isSgtin,
          outlineColor: theme.colorScheme.outlineVariant,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isSgtin) ...[
                Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) onBatchLotFocusLost();
                  },
                  child: Gs1ValidatedField(
                    controller: batchLotController,
                    fieldName: 'batchLotNumber',
                    label: 'Batch/Lot Number *',
                    hintText: 'Enter batch or lot number',
                    validator: CommissioningFieldValidators
                        .validateBatchLotNumberRequired,
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
              ],
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
        ),
      ],
    );
  }
}
