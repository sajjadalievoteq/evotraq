import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_scanned_items_list.dart';

/// Step 2: scan or manually enter child items to receive.
class ReceivingItemScanStep extends StatelessWidget {
  const ReceivingItemScanStep({
    super.key,
    required this.scannedEpcs,
    required this.onItemAdded,
    required this.onRemoveItem,
    required this.onClearAll,
    this.allowedTypes,
    this.fillHeight = false,
    this.showPageHeader = true,
  });

  final List<String> scannedEpcs;
  final void Function(EPCParseResult result) onItemAdded;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onClearAll;
  final List<EPCType>? allowedTypes;
  final bool fillHeight;
  final bool showPageHeader;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    final scanInput = Gs1GroupCard(
      title: 'Add EPCs to Receive',
      outlineColor: outline,
      margin: EdgeInsets.zero,
      child: EPCInputWidget(
        label: 'Item Barcode',
        placeholder: 'Enter GTIN, SGTIN, or barcode',
        allowedTypes: allowedTypes ??
            const [EPCType.sgtin, EPCType.sscc, EPCType.gtin],
        onItemAdded: onItemAdded,
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
              const Text(
                'Scan SGTIN or SSCC labels for this receipt.',
                style: TextStyle(color: Colors.grey),
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
