import 'package:flutter/material.dart';

import 'package:traqtrace_app/core/models/scan_result.dart';

import 'package:traqtrace_app/core/utils/responsive_utils.dart';

import 'package:traqtrace_app/core/widgets/barcode_scanner.dart';

import 'package:traqtrace_app/core/widgets/gln_selector.dart';

import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_container_manual_entry_card.dart';

import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_container_selected_card.dart';

import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_scanning_mode_selector.dart';

import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scanning_mode.dart';



/// Step 1: unpacking reference, location, container, and GS1 business transactions.

class UnpackingReferenceDetailsStep extends StatelessWidget {

  const UnpackingReferenceDetailsStep({

    super.key,

    required this.referenceController,

    required this.workOrderController,

    required this.batchNumberController,

    required this.productionOrderController,

    required this.unpackingLocationGln,

    required this.unpackingLocationGlnError,

    required this.onUnpackingLocationChanged,

    required this.parentContainerId,

    required this.scanningMode,

    required this.manualEntryController,

    required this.onScanningModeChanged,

    required this.onContainerScanResult,

    required this.onAddManualContainer,

    required this.onClearContainer,

    this.showPageHeader = true,

    this.showReferenceSection = true,

    this.showLocationSection = true,

    this.showContainerSection = true,

    this.showProductionSection = true,

  });



  final TextEditingController referenceController;

  final TextEditingController workOrderController;

  final TextEditingController batchNumberController;

  final TextEditingController productionOrderController;

  final GLN? unpackingLocationGln;

  final String? unpackingLocationGlnError;

  final ValueChanged<GLN?> onUnpackingLocationChanged;

  final String? parentContainerId;

  final UnpackingScanningMode scanningMode;

  final TextEditingController manualEntryController;

  final ValueChanged<UnpackingScanningMode> onScanningModeChanged;

  final void Function(ScanResult result) onContainerScanResult;

  final VoidCallback onAddManualContainer;

  final VoidCallback onClearContainer;

  final bool showPageHeader;

  final bool showReferenceSection;

  final bool showLocationSection;

  final bool showContainerSection;

  final bool showProductionSection;



  @override

  Widget build(BuildContext context) {

    final outline = Theme.of(context).colorScheme.outlineVariant;



    return SingleChildScrollView(

      physics: const ClampingScrollPhysics(),

      padding: EdgeInsets.fromLTRB(context.padding.top, context.padding.top, context.padding.top, 0),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          if (showPageHeader) ...[

            const Text(

              'Unpacking Reference Details',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

            ),

            const SizedBox(height: 8),

            const Text(

              'Enter the reference information for this unpacking operation.',

              style: TextStyle(color: Colors.grey),

            ),

            const SizedBox(height: 24),

          ],

          if (showReferenceSection)

            Gs1GroupCard(

              title: 'Unpacking Reference',

              outlineColor: outline,

              child: TextField(

                controller: referenceController,

                decoration: const InputDecoration(

                  labelText: 'Unpacking Reference *',

                  hintText: 'e.g., UNPACK-2024-001',

                  border: OutlineInputBorder(),

                  prefixIcon: Icon(Icons.tag),

                ),

              ),

            ),

          if (showLocationSection)

            Gs1GroupCard(

              title: 'Unpacking Location',

              outlineColor: outline,

              child: GLNSelector(

                label: 'Unpacking Location GLN',

                hintText: 'Search and select unpacking location',

                initialValue: unpackingLocationGln,

                isRequired: true,

                errorText: unpackingLocationGlnError,

                onChanged: onUnpackingLocationChanged,

              ),

            ),

          if (showContainerSection)

            Gs1GroupCard(

              title: 'Parent Container',

              outlineColor: outline,

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [

                  if (parentContainerId != null) ...[

                    UnpackingContainerSelectedCard(

                      containerId: parentContainerId!,

                      onClear: onClearContainer,

                    ),

                    const SizedBox(height: 16),

                  ],

                  UnpackingScanningModeSelector(

                    selectedMode: scanningMode,

                    onModeChanged: onScanningModeChanged,

                  ),

                  const SizedBox(height: 16),

                  if (scanningMode == UnpackingScanningMode.scanner)

                    BarcodeScanner(

                      title: 'Scan Container',

                      allowedFormats: const ['SSCC'],

                      onScanResult: onContainerScanResult,

                    )

                  else

                    UnpackingContainerManualEntryCard(

                      controller: manualEntryController,

                      onAdd: onAddManualContainer,

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

                    decoration: const InputDecoration(

                      labelText: 'Work Order Number',

                      hintText: 'e.g., WO-12345',

                      helperText: 'GS1 bizTransactionList: Work Order (btt:wo)',

                      border: OutlineInputBorder(),

                      prefixIcon: Icon(Icons.work),

                    ),

                  ),

                  const SizedBox(height: 16),

                  TextField(

                    controller: batchNumberController,

                    decoration: const InputDecoration(

                      labelText: 'Batch / Lot Number',

                      hintText: 'e.g., BATCH-2024-001',

                      helperText: 'GS1 ILMD: cbvmda:lotNumber — required for FMD / DSCSA',

                      border: OutlineInputBorder(),

                      prefixIcon: Icon(Icons.tag),

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

                      prefixIcon: Icon(Icons.precision_manufacturing),

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


