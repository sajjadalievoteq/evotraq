import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shipping/utils/shipping_scanning_mode.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

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
          icon: TraqIcon(AppAssets.iconQr),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: ShippingScanningMode.manual,
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
