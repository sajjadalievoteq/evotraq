import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/models/commissioning_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step2/commissioning_manual_serial_input.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step2/commissioning_wired_scanner_input.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/widgets/barcode_scanner.dart';

class CommissioningScanInputCard extends StatelessWidget {
  const CommissioningScanInputCard({
    super.key,
    required this.scanningMode,
    required this.wiredScannerController,
    required this.wiredScannerFocusNode,
    required this.manualSerialController,
    required this.isWiredScannerActive,
    required this.onScanningModeChanged,
    required this.onAddSerial,
    required this.onScanResult,
  });

  final CommissioningScanningMode scanningMode;
  final TextEditingController wiredScannerController;
  final FocusNode wiredScannerFocusNode;
  final TextEditingController manualSerialController;
  final bool isWiredScannerActive;
  final ValueChanged<CommissioningScanningMode> onScanningModeChanged;
  final ValueChanged<String> onAddSerial;
  final ValueChanged<ScanResult> onScanResult;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCameraActive =
        scanningMode == CommissioningScanningMode.camera && !kIsWeb;
    final isWiredActive = scanningMode == CommissioningScanningMode.wired;

    return SizedBox(
      width: double.infinity,
      child: Gs1GroupCard(
        title: 'Add Serial Numbers',
        outlineColor: colorScheme.outlineVariant,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (!kIsWeb) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onScanningModeChanged(
                        isCameraActive
                            ? CommissioningScanningMode.manual
                            : CommissioningScanningMode.camera,
                      ),
                      icon: Icon(
                        isCameraActive
                            ? Icons.camera_alt
                            : Icons.camera_alt_outlined,
                        size: 16,
                      ),
                      label: Text(
                        isCameraActive ? 'Stop Camera' : 'Scan with Camera',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: isCameraActive
                          ? OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              side: BorderSide(color: colorScheme.error),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onScanningModeChanged(
                      isWiredActive
                          ? CommissioningScanningMode.manual
                          : CommissioningScanningMode.wired,
                    ),
                    icon: Icon(
                      isWiredActive ? Icons.keyboard : Icons.keyboard_outlined,
                      size: 16,
                    ),
                    label: Text(
                      isWiredActive ? 'Disconnect' : 'Wired Scanner',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: isWiredActive
                        ? OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            if (isCameraActive) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 200,
                  child: BarcodeScanner(onScanResult: onScanResult, height: 200),
                ),
              ),
            ],
            if (isWiredActive) ...[
              const SizedBox(height: 8),
              CommissioningWiredScannerInput(
                controller: wiredScannerController,
                focusNode: wiredScannerFocusNode,
                isActive: isWiredScannerActive,
                onSubmitted: onAddSerial,
              ),
            ],
            const SizedBox(height: 12),
            CommissioningManualSerialInput(
              controller: manualSerialController,
              onAdd: onAddSerial,
            ),
          ],
        ),
      ),
    );
  }
}
