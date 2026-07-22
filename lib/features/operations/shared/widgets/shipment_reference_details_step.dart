import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
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
    this.showDestinationGln = true,
    this.showDocumentSection = true,
    this.readOnlyLocations = false,
    this.documentsRequired = false,
    this.documentsHelperText,
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
  final bool showDestinationGln;
  final bool showDocumentSection;
  final bool readOnlyLocations;
  final bool documentsRequired;
  final String? documentsHelperText;

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
                        prefixIcon: const TraqIcon(NavIcons.shipping),
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
                    if (showDestinationGln) ...[
                      const SizedBox(height: 16),
                      OperationGlnSelector(
                        label: destinationGlnLabel,
                        gln: destinationGln,
                        onChanged: onDestinationGlnChanged,
                        readOnly: true,
                      ),
                    ],
                  ] else ...[
                    OperationGlnSelector(
                      label: sourceGlnLabel,
                      hintText: sourceGlnHint,
                      gln: sourceGln,
                      errorText: sourceGlnError,
                      onChanged: onSourceGlnChanged,
                    ),
                    if (showDestinationGln) ...[
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
              showRequiredStar: documentsRequired,
              outlineColor: outline,
              child: Column(
                children: [
                  if (documentsHelperText != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        documentsHelperText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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
                      decoration: InputDecoration(
                        labelText: documentsRequired &&
                                _shippingT3DocumentFields
                            ? 'Purchase Order Number *'
                            : 'Purchase Order Number',
                        hintText: 'e.g., PO-784511',
                        helperText: documentsRequired &&
                                _shippingT3DocumentFields
                            ? 'At least one of Purchase Order or Despatch Advice is required (DSCSA T3).'
                            : null,
                        helperMaxLines: 2,
                        border: const OutlineInputBorder(),
                        prefixIcon: const TraqIcon(AppAssets.iconReceipt),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (despatchAdviceController != null) ...[
                    TextField(
                      controller: despatchAdviceController,
                      decoration: InputDecoration(
                        labelText: documentsRequired
                            ? 'Despatch Advice Number *'
                            : 'Despatch Advice Number',
                        hintText: 'e.g., DESADV-12001',
                        helperText: documentsRequired && _receivingT3DocumentFields
                            ? 'At least one of RECADV, Invoice, or DESADV is required (DSCSA T3).'
                            : documentsRequired && _shippingT3DocumentFields
                                ? 'At least one of Purchase Order or Despatch Advice is required (DSCSA T3).'
                                : null,
                        helperMaxLines: 2,
                        border: const OutlineInputBorder(),
                        prefixIcon: const TraqIcon(AppAssets.iconDocument),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (receivingAdviceController != null) ...[
                    TextField(
                      controller: receivingAdviceController,
                      decoration: InputDecoration(
                        labelText: documentsRequired &&
                                _receivingT3DocumentFields
                            ? 'Receiving Advice Number (RECADV) *'
                            : 'Receiving Advice Number (RECADV)',
                        hintText: 'e.g., RECADV-2026-0042',
                        helperText: documentsRequired &&
                                _receivingT3DocumentFields
                            ? 'At least one of RECADV, Invoice, or DESADV is required (DSCSA T3).'
                            : 'Optional — EDI Receiving Advice document number (if applicable)',
                        helperMaxLines: 2,
                        border: const OutlineInputBorder(),
                        prefixIcon: const TraqIcon(AppAssets.iconInbox),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (invoiceController != null) ...[
                    TextField(
                      controller: invoiceController,
                      decoration: InputDecoration(
                        labelText: documentsRequired &&
                                _receivingT3DocumentFields
                            ? 'Invoice Number *'
                            : 'Invoice Number',
                        hintText: 'e.g., INV-45021',
                        helperText: documentsRequired &&
                                _receivingT3DocumentFields
                            ? 'At least one of RECADV, Invoice, or DESADV is required (DSCSA T3).'
                            : null,
                        helperMaxLines: 2,
                        border: const OutlineInputBorder(),
                        prefixIcon: const TraqIcon(AppAssets.iconInvoice),
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
                        prefixIcon: TraqIcon(NavIcons.shipping),
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

  
  bool get _shippingT3DocumentFields =>
      purchaseOrderController != null &&
      despatchAdviceController != null &&
      receivingAdviceController == null &&
      invoiceController == null;

  
  bool get _receivingT3DocumentFields =>
      receivingAdviceController != null || invoiceController != null;
}
