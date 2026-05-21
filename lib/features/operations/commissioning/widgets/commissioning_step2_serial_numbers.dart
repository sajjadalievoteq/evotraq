import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/shared/models/scan_result.dart';
import 'package:traqtrace_app/shared/widgets/barcode_scanner.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

import '../../../../core/utils/responsive_utils.dart';

/// Scanning input modes available during commissioning.
enum ScanningMode { camera, wired, manual }

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
  final ScanningMode scanningMode;

  final TextEditingController wiredScannerController;
  final FocusNode wiredScannerFocusNode;
  final TextEditingController manualSerialController;
  final bool isWiredScannerActive;

  final ValueChanged<ScanningMode> onScanningModeChanged;
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
          _ProductSummaryBanner(
            selectedGTIN: selectedGTIN,
            gtinController: gtinController,
            batchLotController: batchLotController,
          ),
          const SizedBox(height: 16),
          _ScanInputCard(
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
          _SerialListHeader(
            count: serialNumbers.length,
            onClearAll: serialNumbers.isNotEmpty ? onClearAll : null,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: serialNumbers.isEmpty
                ? _EmptySerialHint()
                : _SerialList(
                    serialNumbers: serialNumbers,
                    onRemove: onRemoveSerial,
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ProductSummaryBanner extends StatelessWidget {
  const _ProductSummaryBanner({
    required this.selectedGTIN,
    required this.gtinController,
    required this.batchLotController,
  });

  final GTIN? selectedGTIN;
  final TextEditingController gtinController;
  final TextEditingController batchLotController;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.inventory_2),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GTIN: ${selectedGTIN?.gtinCode ?? gtinController.text}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text('Batch: ${batchLotController.text}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanInputCard extends StatelessWidget {
  const _ScanInputCard({
    required this.scanningMode,
    required this.wiredScannerController,
    required this.wiredScannerFocusNode,
    required this.manualSerialController,
    required this.isWiredScannerActive,
    required this.onScanningModeChanged,
    required this.onAddSerial,
    required this.onScanResult,
  });

  final ScanningMode scanningMode;
  final TextEditingController wiredScannerController;
  final FocusNode wiredScannerFocusNode;
  final TextEditingController manualSerialController;
  final bool isWiredScannerActive;
  final ValueChanged<ScanningMode> onScanningModeChanged;
  final ValueChanged<String> onAddSerial;
  final ValueChanged<ScanResult> onScanResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Add Serial Numbers', padding: EdgeInsets.only(bottom: 12)),
            const SizedBox(height: 12),
            SegmentedButton<ScanningMode>(
              segments: [
                if (!kIsWeb)
                  const ButtonSegment(

                    value: ScanningMode.camera,
                    icon: Icon(Icons.camera_alt,size: 14,),
                    label: Text('Camera'),
                  ),
                const ButtonSegment(
                  value: ScanningMode.wired,
                  icon: Icon(Icons.keyboard,size: 14,),
                  label: Text('Scanner'),
                ),
                const ButtonSegment(
                  value: ScanningMode.manual,
                  icon: Icon(Icons.edit, size: 14),
                  label: Text('Manual'),
                ),
              ],
              selected: {scanningMode},
              onSelectionChanged: (s) => onScanningModeChanged(s.first),
            ),
            const SizedBox(height: 16),
            if (scanningMode == ScanningMode.camera && !kIsWeb)
              SizedBox(
                height: 200,
                child: BarcodeScanner(onScanResult: onScanResult, height: 200),
              )
            else if (scanningMode == ScanningMode.wired)
              _WiredScannerInput(
                controller: wiredScannerController,
                focusNode: wiredScannerFocusNode,
                isActive: isWiredScannerActive,
                onSubmitted: onAddSerial,
              )
            else
              _ManualSerialInput(
                controller: manualSerialController,
                onAdd: onAddSerial,
              ),
          ],
        ),
      ),
    );
  }
}

class _WiredScannerInput extends StatelessWidget {
  const _WiredScannerInput({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Scan serial number with barcode scanner',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(
              Icons.keyboard,
              color: isActive ? Colors.green : null,
            ),
            suffixIcon: isActive
                ? const Icon(Icons.sensors, color: Colors.green)
                : null,
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) onSubmitted(value);
          },
        ),
        const SizedBox(height: 8),
        Text(
          isActive
              ? '✓ Scanner active - scan barcode'
              : 'Click the field to activate scanner input',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive ? Colors.green : Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class _ManualSerialInput extends StatelessWidget {
  const _ManualSerialInput({
    required this.controller,
    required this.onAdd,
  });

  final TextEditingController controller;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter serial number',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) onAdd(value);
            },
          ),
        ),
        const SizedBox(width: 8),
        CustomButtonWidget(
          onTap: () => onAdd(controller.text),
          title: 'Add',
        ),
      ],
    );
  }
}

class _SerialListHeader extends StatelessWidget {
  const _SerialListHeader({required this.count, required this.onClearAll});

  final int count;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SectionLabel('Serial Numbers ($count)', padding: EdgeInsets.zero),
        if (onClearAll != null)
          CustomTextButtonWidget(
            title: 'Clear All',
            onTap: onClearAll!,
          ),
      ],
    );
  }
}

class _EmptySerialHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No serial numbers added yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan or enter serial numbers to commission',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _SerialList extends StatelessWidget {
  const _SerialList({required this.serialNumbers, required this.onRemove});

  final List<String> serialNumbers;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: serialNumbers.length,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 4),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          title: Text(serialNumbers[index]),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => onRemove(index),
          ),
        ),
      ),
    );
  }
}
