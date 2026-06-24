import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scanning_mode.dart';

/// Segmented control for scanner vs manual input in unpacking steps.
class UnpackingScanningModeSelector extends StatelessWidget {
  const UnpackingScanningModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final UnpackingScanningMode selectedMode;
  final ValueChanged<UnpackingScanningMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UnpackingScanningMode>(
      segments: const [
        ButtonSegment(
          value: UnpackingScanningMode.scanner,
          icon: Icon(Icons.qr_code_scanner),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: UnpackingScanningMode.manual,
          icon: Icon(Icons.keyboard),
          label: Text('Manual'),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: (modes) => onModeChanged(modes.first),
    );
  }
}
