import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_scanning_mode.dart';

/// Segmented control for scanner vs manual input in packing steps.
class PackingScanningModeSelector extends StatelessWidget {
  const PackingScanningModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final PackingScanningMode selectedMode;
  final ValueChanged<PackingScanningMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PackingScanningMode>(
      segments: const [
        ButtonSegment(
          value: PackingScanningMode.scanner,
          icon: Icon(Icons.qr_code_scanner),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: PackingScanningMode.manual,
          icon: Icon(Icons.keyboard),
          label: Text('Manual'),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: (modes) => onModeChanged(modes.first),
    );
  }
}
