import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shipping/utils/shipping_scanning_mode.dart';

/// Segmented control for scanner vs manual input in shipping steps.
class ShippingScanningModeSelector extends StatelessWidget {
  const ShippingScanningModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final ShippingScanningMode selectedMode;
  final ValueChanged<ShippingScanningMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ShippingScanningMode>(
      segments: const [
        ButtonSegment(
          value: ShippingScanningMode.scanner,
          icon: Icon(Icons.qr_code_scanner),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: ShippingScanningMode.manual,
          icon: Icon(Icons.keyboard),
          label: Text('Manual'),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: (modes) => onModeChanged(modes.first),
    );
  }
}
