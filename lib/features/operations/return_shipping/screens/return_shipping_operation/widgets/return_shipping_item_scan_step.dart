import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation/widgets/return_shipping_scanned_items_list.dart';

/// Step 2: scan or manually enter items for return shipping.
class ReturnShippingItemScanStep extends StatelessWidget {
  const ReturnShippingItemScanStep({
    super.key,
    required this.scannedEpcs,
    required this.onItemAdded,
    required this.onRemoveItem,
    required this.onClearAll,
    this.allowedTypes,
    this.fillHeight = false,
    this.showPageHeader = true,
    this.itemsReadOnly = false,
  });

  final List<String> scannedEpcs;
  final void Function(EPCParseResult result) onItemAdded;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onClearAll;
  final List<EPCType>? allowedTypes;
  final bool fillHeight;
  final bool showPageHeader;
  final bool itemsReadOnly;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    final scanInput = Gs1GroupCard(
      title: 'Add EPCs to Shipment',
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

    final itemsList = ReturnShippingScannedItemsList(
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
              Text(
                itemsReadOnly ? 'Returned Items' : 'Scan Items to Return',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                itemsReadOnly
                    ? 'Serial numbers from the return shipment (read-only).'
                    : 'Scan SGTIN or SSCC labels for this return shipment.',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],
            if (!itemsReadOnly) scanInput,
            if (!itemsReadOnly) const SizedBox(height: 16),
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
          if (!itemsReadOnly) scanInput,
          if (!itemsReadOnly) const SizedBox(height: 16),
          Expanded(child: itemsList),
        ],
      ),
    );
  }
}
