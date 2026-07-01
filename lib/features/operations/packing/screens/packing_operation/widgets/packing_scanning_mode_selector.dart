import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_scanning_mode.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

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
          icon: TraqIcon(AppAssets.iconQr),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: PackingScanningMode.manual,
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
