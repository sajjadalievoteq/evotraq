import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/models/pharma_return_reason.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_auto_reference_notice.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_event_time_tile.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_gln_selector.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/pharma_return_detail_buttons.dart';

class ShipmentReferenceDetailsStep extends StatelessWidget {
  const ShipmentReferenceDetailsStep({
    super.key,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.operationLabel,
    required this.referenceSectionTitle,
    required this.eventTimeLabel,
    required this.sourceGln,
    required this.sourceGlnLabel,
    required this.sourceGlnHint,
    required this.sourceGlnError,
    required this.onSourceGlnChanged,
    required this.destinationGln,
    required this.destinationGlnLabel,
    required this.destinationGlnHint,
    required this.destinationGlnError,
    required this.onDestinationGlnChanged,
    required this.eventTime,
    required this.onEventTimeChanged,
    required this.documentSectionTitle,
    this.eventTimeEmptyLabel = 'Now (at time of submission)',
    this.showPageHeader = true,
    this.showReferenceSection = true,
    this.showLocationSection = true,
    this.showDocumentSection = true,
    this.readOnlyLocations = false,
    this.returnAuthorizationController,
    this.purchaseOrderController,
    this.despatchAdviceController,
    this.receivingAdviceController,
    this.invoiceController,
    this.billOfLadingController,
    this.carrierController,
    this.trackingController,
    this.notesController,
    this.showReturnReasonField = false,
    this.selectedReturnReason,
    this.onReturnReasonChanged,
    this.returnReasonLabel,
    this.productGtin,
    this.productLotNumber,
    this.productExpiryDate,
    this.productQuantity,
    this.productDescription,
    this.productEpcs = const [],
    this.gincNumberController,
    this.extraContent,
  });

  final String pageTitle;
  final String pageSubtitle;
  final String operationLabel;
  final String referenceSectionTitle;
  final String eventTimeLabel;
  final String documentSectionTitle;
  final String eventTimeEmptyLabel;

  final GLN? sourceGln;
  final String sourceGlnLabel;
  final String sourceGlnHint;
  final String? sourceGlnError;
  final ValueChanged<GLN?> onSourceGlnChanged;

  final GLN? destinationGln;
  final String destinationGlnLabel;
  final String destinationGlnHint;
  final String? destinationGlnError;
  final ValueChanged<GLN?> onDestinationGlnChanged;

  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;

  final bool showPageHeader;
  final bool showReferenceSection;
  final bool showLocationSection;
  final bool showDocumentSection;
  final bool readOnlyLocations;

  final TextEditingController? returnAuthorizationController;
  final TextEditingController? purchaseOrderController;
  final TextEditingController? despatchAdviceController;
  final TextEditingController? receivingAdviceController;
  final TextEditingController? invoiceController;
  final TextEditingController? billOfLadingController;
  final TextEditingController? carrierController;
  final TextEditingController? trackingController;
  final TextEditingController? notesController;

  final bool showReturnReasonField;
  final PharmaReturnReason? selectedReturnReason;
  final ValueChanged<PharmaReturnReason?>? onReturnReasonChanged;
  final String? returnReasonLabel;

  final String? productGtin;
  final String? productLotNumber;
  final DateTime? productExpiryDate;
  final int? productQuantity;
  final String? productDescription;
  final List<String> productEpcs;

  final TextEditingController? gincNumberController;

  final Widget? extraContent;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.padding.top,
        context.padding.top,
        context.padding.top,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPageHeader) ...[
            Text(
              pageTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(pageSubtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
          ],
          if (showReferenceSection)
            Gs1GroupCard(
              title: referenceSectionTitle,
              outlineColor: outline,
              child: Column(
                children: [
                  OperationAutoReferenceNotice(operationLabel: operationLabel),
                  if (gincNumberController != null) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: gincNumberController,
                      decoration: InputDecoration(
                        labelText: 'Consignment Reference (GINC)',
                        hintText:
                            'e.g. GINC-2026-0001 or urn:epc:id:ginc:0614141.xyz…',
                        helperText:
                            'Optional but recommended for DSCSA traceability.',
                        helperMaxLines: 2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: outline),
                        ),
                        prefixIcon: const TraqIcon(AppAssets.iconShipment),
                      ),
                    ),
                  ],
                  OperationEventTimeTile(
                    title: eventTimeLabel,
                    nowLabel: eventTimeEmptyLabel,
                    eventTime: eventTime,
                    onEventTimeChanged: onEventTimeChanged,
                    lastDate: DateTime.now(),
                  ),
                ],
              ),
            ),
          if (showLocationSection)
            Gs1GroupCard(
              title: 'Locations',
              showRequiredStar: true,
              outlineColor: outline,
              child: Column(
                children: [
                  if (readOnlyLocations) ...[
                    OperationGlnSelector(
                      label: sourceGlnLabel,
                      gln: sourceGln,
                      onChanged: onSourceGlnChanged,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    OperationGlnSelector(
                      label: destinationGlnLabel,
                      gln: destinationGln,
                      onChanged: onDestinationGlnChanged,
                      readOnly: true,
                    ),
                  ] else ...[
                    OperationGlnSelector(
                      label: sourceGlnLabel,
                      hintText: sourceGlnHint,
                      gln: sourceGln,
                      errorText: sourceGlnError,
                      onChanged: onSourceGlnChanged,
                    ),
                    const SizedBox(height: 16),
                    OperationGlnSelector(
                      label: destinationGlnLabel,
                      hintText: destinationGlnHint,
                      gln: destinationGln,
                      errorText: destinationGlnError,
                      onChanged: onDestinationGlnChanged,
                    ),
                  ],
                ],
              ),
            ),
          if (showReturnReasonField)
            Gs1GroupCard(
              title: 'Reason for Return',
              showRequiredStar: true,
              outlineColor: outline,
              child: DropdownButtonFormField<PharmaReturnReason>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Reason for Return *',
                ),
                value: selectedReturnReason,
                items: PharmaReturnReason.values
                    .map(
                      (reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(reason.label),
                      ),
                    )
                    .toList(),
                onChanged: onReturnReasonChanged,
              ),
            ),
          if (returnReasonLabel != null)
            Gs1GroupCard(
              title: 'Reason for Return',
              outlineColor: outline,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Submitted by receiver'),
                subtitle: Text(returnReasonLabel!),
              ),
            ),
          if (productGtin != null ||
              productLotNumber != null ||
              productEpcs.isNotEmpty)
            PharmaReturnProductCard(
              gtin: productGtin,
              lotNumber: productLotNumber,
              expiryDate: productExpiryDate,
              quantity: productQuantity,
              productDescription: productDescription,
              epcs: productEpcs,
            ),
          if (showDocumentSection && _hasDocumentFields)
            Gs1GroupCard(
              title: documentSectionTitle,
              outlineColor: outline,
              child: Column(
                children: [
                  if (returnAuthorizationController != null) ...[
                    TextField(
                      controller: returnAuthorizationController,
                      decoration: const InputDecoration(
                        labelText: 'Return Authorization Number',
                        hintText: 'e.g., RAN-2026-0001',
                        border: OutlineInputBorder(),
                        prefixIcon: TraqIcon(AppAssets.iconArrowUpR),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (purchaseOrderController != null) ...[
                    TextField(
                      controller: purchaseOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Order Number',
                        hintText: 'e.g., PO-784511',
                        border: OutlineInputBorder(),
                        prefixIcon: TraqIcon(AppAssets.iconReceipt),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (despatchAdviceController != null) ...[
                    TextField(
                      controller: despatchAdviceController,
                      decoration: const InputDecoration(
                        labelText: 'Despatch Advice Number',
                        hintText: 'e.g., DESADV-12001',
                        border: OutlineInputBorder(),
                        prefixIcon: TraqIcon(AppAssets.iconDocument),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (receivingAdviceController != null) ...[
                    TextField(
                      controller: receivingAdviceController,
                      decoration: const InputDecoration(
                        labelText: 'Receiving Advice Number (RECADV)',
                        hintText: 'e.g., RECADV-2026-0042',
                        helperText:
                            'Optional — EDI Receiving Advice document number (if applicable)',
                        border: OutlineInputBorder(),
                        prefixIcon: TraqIcon(AppAssets.iconInbox),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (invoiceController != null) ...[
                    TextField(
                      controller: invoiceController,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Number',
                        hintText: 'e.g., INV-45021',
                        border: OutlineInputBorder(),
                        prefixIcon: TraqIcon(AppAssets.iconInvoice),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (billOfLadingController != null) ...[
                    TextField(
                      controller: billOfLadingController,
                      decoration: const InputDecoration(
                        labelText: 'Bill of Lading Number',
                        hintText: 'e.g., BOL-20260001',
                        border: OutlineInputBorder(),
                        prefixIcon: TraqIcon(AppAssets.iconClipboard),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (carrierController != null) ...[
                    TextField(
                      controller: carrierController,
                      decoration: const InputDecoration(
                        labelText: 'Carrier',
                        hintText: 'e.g., DHL',
                        border: OutlineInputBorder(),
                        prefixIcon: TraqIcon(AppAssets.iconShipment),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (trackingController != null) ...[
                    TextField(
                      controller: trackingController,
                      decoration: const InputDecoration(
                        labelText: 'Tracking Number',
                        hintText: 'e.g., 1Z999AA10123456784',
                        border: OutlineInputBorder(),
                        prefixIcon: TraqIcon(AppAssets.iconQr),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (notesController != null)
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Optional comments about this receipt',
                        border: OutlineInputBorder(),
                        prefixIcon: TraqIcon(AppAssets.iconDocument),
                      ),
                    ),
                ],
              ),
            ),
          ?extraContent,
        ],
      ),
    );
  }

  bool get _hasDocumentFields =>
      returnAuthorizationController != null ||
      purchaseOrderController != null ||
      despatchAdviceController != null ||
      receivingAdviceController != null ||
      invoiceController != null ||
      billOfLadingController != null ||
      carrierController != null ||
      trackingController != null ||
      notesController != null;
}
