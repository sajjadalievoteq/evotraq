import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/receiving/utils/receiving_scanning_mode.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

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
          icon: TraqIcon(AppAssets.iconQr),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: ReceivingScanningMode.manual,
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
