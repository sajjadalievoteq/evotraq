import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/receiving/utils/receiving_scanning_mode.dart';

/// Segmented control for scanner vs manual input in Receiving steps.
class ReceivingScanningModeSelector extends StatelessWidget {
  const ReceivingScanningModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final ReceivingScanningMode selectedMode;
  final ValueChanged<ReceivingScanningMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ReceivingScanningMode>(
      segments: const [
        ButtonSegment(
          value: ReceivingScanningMode.scanner,
          icon: Icon(Icons.qr_code_scanner),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: ReceivingScanningMode.manual,
          icon: Icon(Icons.keyboard),
          label: Text('Manual'),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: (modes) => onModeChanged(modes.first),
    );
  }
}
