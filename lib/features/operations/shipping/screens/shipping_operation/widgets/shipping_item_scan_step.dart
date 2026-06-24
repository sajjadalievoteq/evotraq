import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/barcode_scanner.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_item_manual_entry_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_scanned_items_list.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_scanning_mode_selector.dart';
import 'package:traqtrace_app/features/operations/shipping/utils/shipping_scanning_mode.dart';

/// Step 2: scan or manually enter child items to pack.
class ShippingItemScanStep extends StatelessWidget {
  const ShippingItemScanStep({
    super.key,
    required this.shippingReference,
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

  final String shippingReference;
  final List<String> scannedEpcs;
  final ShippingScanningMode scanningMode;
  final TextEditingController manualEntryController;
  final ValueChanged<ShippingScanningMode> onScanningModeChanged;
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
      title: 'Add EPCs to Shipment',
      outlineColor: outline,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShippingScanningModeSelector(
            selectedMode: scanningMode,
            onModeChanged: onScanningModeChanged,
          ),
          const SizedBox(height: 16),
          if (scanningMode == ShippingScanningMode.scanner)
            BarcodeScanner(
              title: 'Scan SGTIN/SSCC',
              allowedFormats: const ['SGTIN', 'SSCC'],
              onScanResult: onItemScanResult,
            )
          else
            ShippingItemManualEntryCard(
              controller: manualEntryController,
              onAdd: onAddManualItem,
            ),
        ],
      ),
    );

    final itemsList = ShippingScannedItemsList(
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
                'Scan SGTIN or SSCC labels for shipment ${shippingReference.isEmpty ? '' : '($shippingReference)'}',
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
