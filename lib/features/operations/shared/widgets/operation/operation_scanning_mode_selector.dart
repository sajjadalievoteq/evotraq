import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_scanning_mode.dart';

/// Shared scanner/manual segmented control for operation wizard screens.
class OperationScanningModeSelector extends StatelessWidget {
  const OperationScanningModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final OperationScanningMode selectedMode;
  final ValueChanged<OperationScanningMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<OperationScanningMode>(
      segments: const [
        ButtonSegment(
          value: OperationScanningMode.scanner,
          icon: TraqIcon(AppAssets.iconQr),
          label: Text('Camera / Scanner'),
        ),
        ButtonSegment(
          value: OperationScanningMode.manual,
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
