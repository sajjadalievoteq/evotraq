import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/decommissioning/utils/decommissioning_scanning_mode.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Segmented control for scanner vs manual input in Decommissioning steps.
class DecommissioningScanningModeSelector extends StatelessWidget {
  const DecommissioningScanningModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final DecommissioningScanningMode selectedMode;
  final ValueChanged<DecommissioningScanningMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DecommissioningScanningMode>(
      segments: const [
        ButtonSegment(
          value: DecommissioningScanningMode.scanner,
          icon: TraqIcon(AppAssets.iconQr),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: DecommissioningScanningMode.manual,
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
