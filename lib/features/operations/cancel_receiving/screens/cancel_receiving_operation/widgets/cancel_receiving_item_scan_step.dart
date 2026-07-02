import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/widgets/cancel_receiving_scanned_items_list.dart';

class CancelReceivingItemScanStep extends StatelessWidget {
  const CancelReceivingItemScanStep({
    super.key,
    required this.scannedEpcs,
    required this.onItemAdded,
    required this.onRemoveItem,
    required this.onClearAll,
    this.fillHeight = false,
    this.showPageHeader = true,
  });

  final List<String> scannedEpcs;
  final void Function(EPCParseResult result) onItemAdded;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onClearAll;
  final bool fillHeight;
  final bool showPageHeader;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    final warningBanner = Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'DSCSA / EU FMD: Only serialized SGTINs and SSCCs accepted. '
              'Lot-based GTINs (lgtin) will be rejected.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );

    final scanInput = Gs1GroupCard(
      title: 'Add EPCs to Cancel',
      outlineColor: outline,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          warningBanner,
          EPCInputWidget(
            label: 'Item Barcode',
            placeholder: 'Enter SGTIN or SSCC barcode',
            allowedTypes: const [EPCType.sgtin, EPCType.sscc],
            onItemAdded: onItemAdded,
          ),
        ],
      ),
    );

    final itemsList = CancelReceivingScannedItemsList(
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
                'Scan Items to Cancel',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan serialized SGTINs or SSCCs only. Lot-based GTINs (lgtin) are not valid for cancel receiving under DSCSA/FMD.',
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
