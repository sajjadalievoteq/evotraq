import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/barcode_scanner.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_container_manual_entry_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_container_selected_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_scanning_mode_selector.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_auto_reference_notice.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_event_time_tile.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_gln_selector.dart';



class ContainerOperationReferenceDetailsStep extends StatelessWidget {
  const ContainerOperationReferenceDetailsStep({
    super.key,
    required this.isUnpacking,
    required this.padWorkOrderBatchIcons,
    required this.workOrderController,
    required this.batchNumberController,
    required this.productionOrderController,
    required this.locationGln,
    required this.locationGlnError,
    required this.onLocationChanged,
    required this.parentContainerId,
    required this.scanningMode,
    required this.onScanningModeChanged,
    required this.onContainerScanResult,
    required this.onContainerAdded,
    required this.onClearContainer,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
    this.showReferenceSection = true,
    this.showLocationSection = true,
    this.showContainerSection = true,
    this.showProductionSection = true,
  });

  final bool isUnpacking;
  final bool padWorkOrderBatchIcons;
  final TextEditingController workOrderController;
  final TextEditingController batchNumberController;
  final TextEditingController productionOrderController;
  final GLN? locationGln;
  final String? locationGlnError;
  final ValueChanged<GLN?> onLocationChanged;
  final String? parentContainerId;
  final OperationScanningMode scanningMode;
  final ValueChanged<OperationScanningMode> onScanningModeChanged;
  final void Function(ScanResult result) onContainerScanResult;
  final void Function(EPCParseResult result) onContainerAdded;
  final VoidCallback onClearContainer;
  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final bool showPageHeader;
  final bool showReferenceSection;
  final bool showLocationSection;
  final bool showContainerSection;
  final bool showProductionSection;

  String get _operationLabel => isUnpacking ? 'Unpacking' : 'Packing';

  Widget _prefixIcon(String asset, {required bool pad}) {
    final icon = TraqIcon(asset);
    if (!pad) return icon;
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: icon,
    );
  }

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
              '$_operationLabel Reference Details',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the reference information for this '
              '${isUnpacking ? 'unpacking' : 'packing'} operation.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
          ],
          if (showReferenceSection)
            Gs1GroupCard(
              title: '$_operationLabel Reference',
              outlineColor: outline,
              child: Column(
                children: [
                  OperationAutoReferenceNotice(operationLabel: _operationLabel),
                  OperationEventTimeTile(
                    eventTime: eventTime,
                    onEventTimeChanged: onEventTimeChanged,
                    lastDate: DateTime.now(),
                  ),
                ],
              ),
            ),
          if (showLocationSection)
            Gs1GroupCard(
              title: '$_operationLabel Location',
              showRequiredStar: true,
              outlineColor: outline,
              child: OperationGlnSelector(
                label: '$_operationLabel Location GLN',
                hintText:
                    'Search and select ${isUnpacking ? 'unpacking' : 'packing'} location',
                gln: locationGln,
                errorText: locationGlnError,
                onChanged: onLocationChanged,
              ),
            ),
          if (showContainerSection)
            Gs1GroupCard(
              title: 'Parent Container',
              showRequiredStar: true,
              outlineColor: outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Identify the parent logistic unit — SSCC (carton/pallet) '
                    'or SGTIN (serialized product acting as container).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (parentContainerId != null) ...[
                    OperationContainerSelectedCard(
                      containerId: parentContainerId!,
                      onClear: onClearContainer,
                    ),
                    const SizedBox(height: 16),
                  ],
                  OperationScanningModeSelector(
                    selectedMode: scanningMode,
                    onModeChanged: onScanningModeChanged,
                  ),
                  const SizedBox(height: 16),
                  if (scanningMode == OperationScanningMode.scanner)
                    BarcodeScanner(
                      title: 'Scan Container',
                      allowedFormats: const ['SSCC', 'SGTIN'],
                      onScanResult: onContainerScanResult,
                    )
                  else
                    OperationContainerManualEntryCard(
                      onContainerAdded: onContainerAdded,
                    ),
                ],
              ),
            ),
          if (showProductionSection)
            Gs1GroupCard(
              title: 'GS1 Business Transactions (Optional)',
              outlineColor: outline,
              child: Column(
                children: [
                  TextField(
                    controller: workOrderController,
                    decoration: InputDecoration(
                      labelText: 'Work Order Number',
                      hintText: 'e.g., WO-12345',
                      helperText: 'GS1 bizTransactionList: Work Order (btt:wo)',
                      border: const OutlineInputBorder(),
                      prefixIcon: _prefixIcon(
                        AppAssets.iconList,
                        pad: padWorkOrderBatchIcons,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: batchNumberController,
                    decoration: InputDecoration(
                      labelText: 'Batch / Lot Number',
                      hintText: 'e.g., BATCH-2024-001',
                      helperText:
                          'GS1 ILMD: cbvmda:lotNumber — required for FMD / DSCSA',
                      border: const OutlineInputBorder(),
                      prefixIcon: _prefixIcon(
                        AppAssets.iconPin,
                        pad: padWorkOrderBatchIcons,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: productionOrderController,
                    decoration: const InputDecoration(
                      labelText: 'Production Order',
                      hintText: 'e.g., PO-2024-001',
                      helperText:
                          'GS1 bizTransactionList: Production Order (btt:prodorder)',
                      border: OutlineInputBorder(),
                      prefixIcon: TraqIcon(NavIcons.commissioning),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
