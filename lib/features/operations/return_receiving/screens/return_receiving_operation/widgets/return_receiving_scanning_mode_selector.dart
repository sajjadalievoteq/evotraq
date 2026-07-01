import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/return_receiving/utils/return_receiving_scanning_mode.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Segmented control for scanner vs manual input in ReturnReceiving steps.
class ReturnReceivingScanningModeSelector extends StatelessWidget {
  const ReturnReceivingScanningModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final ReturnReceivingScanningMode selectedMode;
  final ValueChanged<ReturnReceivingScanningMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ReturnReceivingScanningMode>(
      segments: const [
        ButtonSegment(
          value: ReturnReceivingScanningMode.scanner,
          icon: TraqIcon(AppAssets.iconQr),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: ReturnReceivingScanningMode.manual,
          icon: TraqIcon(AppAssets.iconKeyboard),
          label: Text('Manual'),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: (modes) {
        if (modes.isEmpty) return;
        onModeChanged(modes.first);
      },
    );
  }
}
