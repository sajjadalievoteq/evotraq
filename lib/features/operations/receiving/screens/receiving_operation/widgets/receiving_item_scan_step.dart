import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/barcode_scanner.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_item_manual_entry_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_scanned_items_list.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_scanning_mode_selector.dart';
import 'package:traqtrace_app/features/operations/receiving/utils/receiving_scanning_mode.dart';

/// Step 2: scan or manually enter child items to pack.
class ReceivingItemScanStep extends StatelessWidget {
  const ReceivingItemScanStep({
    super.key,
    required this.receivingReference,
    required this.scannedEpcs,
    required this.scanningMode,
    required this.manualEntryController,
    required this.onScanningModeChanged,
    required this.onItemScanResult,
    required this.onAddManualItem,
    required this.onRemoveItem,
    required this.onClearAll,
    this.fillHeight = false,
    this.showPageHeader = true,
  });

  final String receivingReference;
  final List<String> scannedEpcs;
  final ReceivingScanningMode scanningMode;
  final TextEditingController manualEntryController;
  final ValueChanged<ReceivingScanningMode> onScanningModeChanged;
  final void Function(ScanResult result) onItemScanResult;
  final VoidCallback onAddManualItem;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onClearAll;
  final bool fillHeight;
  final bool showPageHeader;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    final scanInput = Gs1GroupCard(
      title: 'Add EPCs to Receive',
      outlineColor: outline,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReceivingScanningModeSelector(
            selectedMode: scanningMode,
            onModeChanged: onScanningModeChanged,
          ),
          const SizedBox(height: 16),
          if (scanningMode == ReceivingScanningMode.scanner)
            BarcodeScanner(
              title: 'Scan SGTIN/SSCC',
              allowedFormats: const ['SGTIN', 'SSCC'],
              onScanResult: onItemScanResult,
            )
          else
            ReceivingItemManualEntryCard(
              controller: manualEntryController,
              onAdd: onAddManualItem,
            ),
        ],
      ),
    );

    final itemsList = ReceivingScannedItemsList(
      scannedEpcs: scannedEpcs,
      onRemoveItem: onRemoveItem,
      onClearAll: onClearAll,
    );

    if (!fillHeight) {
      return SingleChildScrollView(
        padding: context.horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPageHeader) ...[
              const Text(
                'Scan Items to Ship',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan SGTIN or SSCC labels for shipment ${receivingReference.isEmpty ? '' : '($receivingReference)'}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],
            scanInput,
            const SizedBox(height: 16),
            itemsList,
          ],
        ),
      );
    }

    return Padding(
      padding: ResponsiveUtils.paddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          scanInput,
          const SizedBox(height: 16),
          Expanded(child: itemsList),
        ],
      ),
    );
  }
}
