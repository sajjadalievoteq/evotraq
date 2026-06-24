import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/barcode_scanner.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_container_summary_banner.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_item_manual_entry_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_scanned_items_list.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_scanning_mode_selector.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_scanning_mode.dart';

/// Step 2: scan or manually enter child items to pack.
class PackingItemScanStep extends StatelessWidget {
  const PackingItemScanStep({
    super.key,
    required this.parentContainerId,
    required this.packingReference,
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

  final String? parentContainerId;
  final String packingReference;
  final List<String> scannedEpcs;
  final PackingScanningMode scanningMode;
  final TextEditingController manualEntryController;
  final ValueChanged<PackingScanningMode> onScanningModeChanged;
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
      title: 'Add Items to Pack',
      outlineColor: outline,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PackingScanningModeSelector(
            selectedMode: scanningMode,
            onModeChanged: onScanningModeChanged,
          ),
          const SizedBox(height: 16),
          if (scanningMode == PackingScanningMode.scanner)
            BarcodeScanner(
              title: 'Scan Item',
              allowedFormats: const ['SGTIN', 'GTIN'],
              onScanResult: onItemScanResult,
            )
          else
            PackingItemManualEntryCard(
              controller: manualEntryController,
              onAdd: onAddManualItem,
            ),
        ],
      ),
    );

    final itemsList = PackingScannedItemsList(
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
                'Scan Items to Pack',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan the items to be packed into container: ${parentContainerId ?? 'Unknown'}',
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
          PackingContainerSummaryBanner(
            parentContainerId: parentContainerId,
            packingReference: packingReference,
          ),
          const SizedBox(height: 16),
          scanInput,
          const SizedBox(height: 16),
          Expanded(child: itemsList),
        ],
      ),
    );
  }
}
