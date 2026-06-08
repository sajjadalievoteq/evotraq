import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/models/commissioning_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step2/commissioning_empty_serial_hint.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step2/commissioning_product_summary_banner.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step2/commissioning_scan_input_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step2/commissioning_serial_list.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step2/commissioning_serial_list_header.dart';
import 'package:traqtrace_app/shared/models/scan_result.dart';

import '../../../../../../core/utils/responsive_utils.dart';

/// Step 2 of the commissioning wizard — scan or enter serial numbers.
class CommissioningStep2SerialNumbers extends StatelessWidget {
  const CommissioningStep2SerialNumbers({
    super.key,
    required this.selectedGTIN,
    required this.gtinController,
    required this.batchLotController,
    required this.serialNumbers,
    required this.scanningMode,
    required this.wiredScannerController,
    required this.wiredScannerFocusNode,
    required this.manualSerialController,
    required this.isWiredScannerActive,
    required this.onScanningModeChanged,
    required this.onAddSerial,
    required this.onRemoveSerial,
    required this.onClearAll,
    required this.onScanResult,
  });

  final GTIN? selectedGTIN;
  final TextEditingController gtinController;
  final TextEditingController batchLotController;

  final List<String> serialNumbers;
  final CommissioningScanningMode scanningMode;

  final TextEditingController wiredScannerController;
  final FocusNode wiredScannerFocusNode;
  final TextEditingController manualSerialController;
  final bool isWiredScannerActive;

  final ValueChanged<CommissioningScanningMode> onScanningModeChanged;
  final ValueChanged<String> onAddSerial;
  final ValueChanged<int> onRemoveSerial;
  final VoidCallback onClearAll;
  final ValueChanged<ScanResult> onScanResult;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.paddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommissioningProductSummaryBanner(
            selectedGTIN: selectedGTIN,
            gtinController: gtinController,
            batchLotController: batchLotController,
          ),
          const SizedBox(height: 16),
          CommissioningScanInputCard(
            scanningMode: scanningMode,
            wiredScannerController: wiredScannerController,
            wiredScannerFocusNode: wiredScannerFocusNode,
            manualSerialController: manualSerialController,
            isWiredScannerActive: isWiredScannerActive,
            onScanningModeChanged: onScanningModeChanged,
            onAddSerial: onAddSerial,
            onScanResult: onScanResult,
          ),
          const SizedBox(height: 16),
          CommissioningSerialListHeader(
            count: serialNumbers.length,
            onClearAll: serialNumbers.isNotEmpty ? onClearAll : null,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: serialNumbers.isEmpty
                ? const CommissioningEmptySerialHint()
                : CommissioningSerialList(
                    serialNumbers: serialNumbers,
                    onRemove: onRemoveSerial,
                  ),
          ),
        ],
      ),
    );
  }
}
