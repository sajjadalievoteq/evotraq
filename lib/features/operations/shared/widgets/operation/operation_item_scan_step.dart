import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_scanned_items_list.dart';

class OperationItemScanStep extends StatelessWidget {
  const OperationItemScanStep({
    super.key,
    required this.scannedEpcs,
    required this.onItemAdded,
    required this.onRemoveItem,
    required this.onClearAll,
    required this.groupCardTitle,
    required this.pageHeaderTitle,
    required this.pageHeaderSubtitle,
    required this.scannedListTitle,
    required this.scannedQueuedLabel,
    required this.hierarchyScreenTitle,
    this.allowedTypes,
    this.fillHeight = false,
    this.showPageHeader = true,
    this.showScanInput = true,
    this.itemWarnings = const {},
    this.onParseFallback,
    this.betweenScanAndList,
    this.itemProductNames = const {},
  });

  final List<String> scannedEpcs;
  final void Function(EPCParseResult result) onItemAdded;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onClearAll;
  final String groupCardTitle;
  final String pageHeaderTitle;
  final String pageHeaderSubtitle;
  final String scannedListTitle;
  final String scannedQueuedLabel;
  final String hierarchyScreenTitle;
  final List<EPCType>? allowedTypes;
  final bool fillHeight;
  final bool showPageHeader;
  final bool showScanInput;
  final Map<String, String> itemWarnings;
  final Future<EPCParseResult?> Function(String input)? onParseFallback;
  final Widget? betweenScanAndList;
  final Map<String, String> itemProductNames;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    final scanInput = Gs1GroupCard(
      title: groupCardTitle,
      outlineColor: outline,
      margin: EdgeInsets.zero,
      child: EPCInputWidget(
        label: 'Item Barcode',
        placeholder: 'Enter SGTIN or SSCC barcode',
        allowedTypes: allowedTypes ??
            const [EPCType.sgtin, EPCType.sscc],
        onParseFallback: onParseFallback,
        onItemAdded: onItemAdded,
      ),
    );

    final itemsList = OperationScannedItemsList(
      scannedEpcs: scannedEpcs,
      onRemoveItem: onRemoveItem,
      onClearAll: onClearAll,
      listTitle: scannedListTitle,
      queuedLabel: scannedQueuedLabel,
      hierarchyScreenTitle: hierarchyScreenTitle,
      itemWarnings: itemWarnings,
      itemProductNames: itemProductNames,
    );

    if (!fillHeight) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.padding.top, context.padding.top, context.padding.top, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPageHeader) ...[
              Text(
                pageHeaderTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pageHeaderSubtitle,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],
            if (showScanInput) scanInput,
            if (showScanInput) const SizedBox(height: 16),
            if (betweenScanAndList != null) ...[
              betweenScanAndList!,
              const SizedBox(height: 16),
            ],
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
          if (showScanInput) scanInput,
          if (showScanInput) const SizedBox(height: 16),
          if (betweenScanAndList != null) ...[
            betweenScanAndList!,
          ],
          Expanded(child: itemsList),
        ],
      ),
    );
  }
}
