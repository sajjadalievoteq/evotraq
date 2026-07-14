import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/container_operation_reference_details_step.dart';

class PackingReferenceDetailsStep extends StatelessWidget {
  const PackingReferenceDetailsStep({
    super.key,
    required this.workOrderController,
    required this.batchNumberController,
    required this.productionOrderController,
    required this.packingLocationGln,
    required this.packingLocationGlnError,
    required this.onPackingLocationChanged,
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

  final TextEditingController workOrderController;
  final TextEditingController batchNumberController;
  final TextEditingController productionOrderController;
  final GLN? packingLocationGln;
  final String? packingLocationGlnError;
  final ValueChanged<GLN?> onPackingLocationChanged;
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

  @override
  Widget build(BuildContext context) {
    return ContainerOperationReferenceDetailsStep(
      isUnpacking: false,
      padWorkOrderBatchIcons: true,
      workOrderController: workOrderController,
      batchNumberController: batchNumberController,
      productionOrderController: productionOrderController,
      locationGln: packingLocationGln,
      locationGlnError: packingLocationGlnError,
      onLocationChanged: onPackingLocationChanged,
      parentContainerId: parentContainerId,
      scanningMode: scanningMode,
      onScanningModeChanged: onScanningModeChanged,
      onContainerScanResult: onContainerScanResult,
      onContainerAdded: onContainerAdded,
      onClearContainer: onClearContainer,
      eventTime: eventTime,
      onEventTimeChanged: onEventTimeChanged,
      showPageHeader: showPageHeader,
      showReferenceSection: showReferenceSection,
      showLocationSection: showLocationSection,
      showContainerSection: showContainerSection,
      showProductionSection: showProductionSection,
    );
  }
}
