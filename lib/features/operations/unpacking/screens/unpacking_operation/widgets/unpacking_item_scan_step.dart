import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/operations/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_item_manual_entry_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_container_contents_table.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_container_summary_banner.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_scope_selector.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scope.dart';

class UnpackingItemScanStep extends StatelessWidget {
  const UnpackingItemScanStep({
    super.key,
    required this.parentContainerId,
    required this.scope,
    required this.onScopeChanged,
    required this.containerContents,
    required this.selectedEpcs,
    required this.onItemSelectionChanged,
    required this.itemScanningMode,
    required this.onItemScanningModeChanged,
    required this.onItemAdded,
    this.isLoadingContents = false,
    this.contentsLoadError,
    this.onRetryLoadContents,
    this.allowedTypes,
    this.fillHeight = false,
    this.showPageHeader = true,
  });

  final String? parentContainerId;
  final UnpackingScope scope;
  final ValueChanged<UnpackingScope> onScopeChanged;
  final List<HierarchyNode> containerContents;
  final Set<String> selectedEpcs;
  final void Function(String epc, bool selected) onItemSelectionChanged;
  final OperationScanningMode itemScanningMode;
  final ValueChanged<OperationScanningMode> onItemScanningModeChanged;
  final void Function(EPCParseResult result) onItemAdded;
  final bool isLoadingContents;
  final String? contentsLoadError;
  final VoidCallback? onRetryLoadContents;
  final List<EPCType>? allowedTypes;
  final bool fillHeight;
  final bool showPageHeader;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final isPartial = scope == UnpackingScope.partial;
    final allowed = allowedTypes ??
        const [EPCType.sgtin, EPCType.sscc];

    final scopeCard = Gs1GroupCard(
      title: 'Unpack scope',
      outlineColor: outline,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UnpackingScopeSelector(
            selectedScope: scope,
            onScopeChanged: onScopeChanged,
          ),
          const SizedBox(height: 8),
          Text(
            isPartial
                ? 'Unpack some or all items. Use the packed-items table, a scanner, or manual EPC entry.'
                : 'Every direct child of this container will be unpacked.',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );

    final contentsTable = UnpackingContainerContentsTable(
      parentContainerId: parentContainerId,
      contents: containerContents,
      scope: scope,
      selectedEpcs: selectedEpcs,
      onSelectionChanged: onItemSelectionChanged,
      isLoading: isLoadingContents,
      loadError: contentsLoadError,
      onRetry: onRetryLoadContents,
    );

    final addItemsCard = isPartial
        ? Gs1GroupCard(
            title: 'Add item by scan or manual entry',
            outlineColor: outline,
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Alternatively, scan or type an EPC — it must match an item '
                  'listed in the table above.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 16),
                if (itemScanningMode == OperationScanningMode.scanner)
                  EPCInputWidget(
                    label: 'Item Barcode',
                    placeholder: 'Scan SGTIN or SSCC barcode',
                    allowedTypes: allowed,
                    onItemAdded: onItemAdded,
                  )
                else
                  OperationItemManualEntryCard(
                    onItemAdded: onItemAdded,
                    allowedTypes: allowed,
                  ),
              ],
            ),
          )
        : const SizedBox.shrink();

    if (!fillHeight) {
      return SingleChildScrollView(
        padding: context.horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPageHeader) ...[
              const Text(
                'Items to Unpack',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Container: ${parentContainerId ?? 'Unknown'}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],
            scopeCard,
            const SizedBox(height: 16),
            contentsTable,
            if (isPartial) ...[
              const SizedBox(height: 16),
              addItemsCard,
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: ResponsiveUtils.paddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OperationContainerSummaryBanner(
            parentContainerId: parentContainerId,
          ),
          const SizedBox(height: 16),
          scopeCard,
          const SizedBox(height: 16),
          Expanded(child: contentsTable),
          if (isPartial) ...[
            const SizedBox(height: 16),
            addItemsCard,
          ],
        ],
      ),
    );
  }
}
