import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/return_shipping/utils/return_shipping_scanning_mode.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Segmented control for scanner vs manual input in shipping steps.
class ReturnShippingScanningModeSelector extends StatelessWidget {
  const ReturnShippingScanningModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final ReturnShippingScanningMode selectedMode;
  final ValueChanged<ReturnShippingScanningMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ReturnShippingScanningMode>(
      segments: const [
        ButtonSegment(
          value: ReturnShippingScanningMode.scanner,
          icon: TraqIcon(AppAssets.iconQr),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: ReturnShippingScanningMode.manual,
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
