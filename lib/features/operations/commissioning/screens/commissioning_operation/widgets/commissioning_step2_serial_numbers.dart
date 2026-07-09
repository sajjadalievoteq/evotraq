import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_dates_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_item_scan_step.dart';

/// Plain item scan step — matches Update Status operation layout.
class CommissioningStep2SerialNumbers extends StatelessWidget {
  const CommissioningStep2SerialNumbers({
    super.key,
    required this.scannedEpcs,
    required this.onItemAdded,
    required this.onRemoveItem,
    required this.onClearAll,
    required this.batchLotController,
    required this.expiryDate,
    required this.productionDate,
    required this.bestBeforeDate,
    required this.onSelectDate,
    required this.onClearDate,
    required this.onBatchLotEditingComplete,
    required this.onBatchLotFocusLost,
    required this.registrationQuantityController,
    required this.onSelectRegistrationDate,
    required this.onClearRegistrationDate,
    required this.onRegisterBatch,
    required this.onToggleRegistrationPanel,
    this.identifiedType,
    this.onParseFallback,
    this.embeddedInPanel = false,
    this.fillHeight = false,
    this.showPharmaBatchLookup = false,
    this.batchLookupStatus = CommissioningBatchLookupStatus.idle,
    this.resolvedBatch,
    this.batchLookupError,
    this.registrationPanelExpanded = false,
    this.registrationExpiryDate,
    this.registrationManufactureDate,
    this.isBatchRegistering = false,
    this.stepFormKey,
    this.itemProductNames = const {},
  });

  final List<String> scannedEpcs;
  final void Function(EPCParseResult result) onItemAdded;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onClearAll;
  final Future<EPCParseResult?> Function(String input)? onParseFallback;
  final bool embeddedInPanel;
  final bool fillHeight;

  final EPCType? identifiedType;
  final TextEditingController batchLotController;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onClearDate;
  final VoidCallback onBatchLotEditingComplete;
  final VoidCallback onBatchLotFocusLost;
  final TextEditingController registrationQuantityController;
  final ValueChanged<String> onSelectRegistrationDate;
  final ValueChanged<String> onClearRegistrationDate;
  final VoidCallback onRegisterBatch;
  final ValueChanged<bool> onToggleRegistrationPanel;
  final bool showPharmaBatchLookup;
  final CommissioningBatchLookupStatus batchLookupStatus;
  final GtinBatch? resolvedBatch;
  final String? batchLookupError;
  final bool registrationPanelExpanded;
  final DateTime? registrationExpiryDate;
  final DateTime? registrationManufactureDate;
  final bool isBatchRegistering;
  final GlobalKey<FormState>? stepFormKey;
  final Map<String, String> itemProductNames;

  bool get _showBatchDates => identifiedType == EPCType.sgtin;

  @override
  Widget build(BuildContext context) {
    final batchDatesCard = _showBatchDates
        ? CommissioningBatchDatesCard(
            batchLotController: batchLotController,
            expiryDate: expiryDate,
            productionDate: productionDate,
            bestBeforeDate: bestBeforeDate,
            onSelectDate: onSelectDate,
            onClearDate: onClearDate,
            onBatchLotEditingComplete: onBatchLotEditingComplete,
            onBatchLotFocusLost: onBatchLotFocusLost,
            registrationQuantityController: registrationQuantityController,
            onSelectRegistrationDate: onSelectRegistrationDate,
            onClearRegistrationDate: onClearRegistrationDate,
            onRegisterBatch: onRegisterBatch,
            onToggleRegistrationPanel: onToggleRegistrationPanel,
            showPharmaBatchLookup: showPharmaBatchLookup,
            batchLookupStatus: batchLookupStatus,
            resolvedBatch: resolvedBatch,
            batchLookupError: batchLookupError,
            registrationPanelExpanded: registrationPanelExpanded,
            registrationExpiryDate: registrationExpiryDate,
            registrationManufactureDate: registrationManufactureDate,
            isBatchRegistering: isBatchRegistering,
          )
        : null;

    final scanStep = OperationItemScanStep(
      scannedEpcs: scannedEpcs,
      onItemAdded: onItemAdded,
      onRemoveItem: onRemoveItem,
      onClearAll: onClearAll,
      groupCardTitle: 'Add EPCs to Commission',
      pageHeaderTitle: 'Scan Items to Commission',
      pageHeaderSubtitle: 'Scan SGTIN or SSCC labels to commission.',
      scannedListTitle: 'Items to Commission',
      scannedQueuedLabel: 'queued for commissioning',
      hierarchyScreenTitle: 'Commissioning Hierarchy',
      allowedTypes: const [EPCType.sgtin, EPCType.sscc],
      onParseFallback: onParseFallback,
      fillHeight: fillHeight,
      showPageHeader: !embeddedInPanel,
      betweenScanAndList: batchDatesCard,
      itemProductNames: itemProductNames,
    );

    if (stepFormKey == null || batchDatesCard == null) {
      return scanStep;
    }

    return Form(
      key: stepFormKey,
      child: scanStep,
    );
  }
}
