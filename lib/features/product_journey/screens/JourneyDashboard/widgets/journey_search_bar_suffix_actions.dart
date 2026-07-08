import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scan_dialog.dart';

class JourneySearchBarSuffixActions extends StatelessWidget {
  const JourneySearchBarSuffixActions({
    super.key,
    required this.controller,
    required this.onClear,
    this.onScanResult,
  });

  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<ScanResult>? onScanResult;

  static const double fieldIconSize = 18;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasText = controller.text.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onScanResult != null)
          IconButton(
            padding: EdgeInsets.zero,
            tooltip: 'Scan barcode',
            icon: TraqIcon(AppAssets.iconQr, size: fieldIconSize),
            color: c.primary,
            onPressed: () async {
              final result = await GS1BarcodeScanDialog.show(
                context,
                title: 'Scan Identifier',
              );
              if (result != null && result.isValid) {
                onScanResult!(result);
              }
            },
          ),
        if (hasText)
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: onClear,
            iconSize: fieldIconSize,
            icon: TraqIcon(AppAssets.iconX, size: fieldIconSize),
            color: c.textMuted,
            tooltip: 'Clear',
          ),
      ],
    );
  }
}
