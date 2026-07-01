import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scanning_mode.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

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
          icon: TraqIcon(AppAssets.iconQr),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: UnpackingScanningMode.manual,
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
