import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gs1_field_barcode_scan.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class Gs1FieldScanSuffixIcon extends StatelessWidget {
  const Gs1FieldScanSuffixIcon({
    super.key,
    required this.kind,
    required this.onScanned,
  });

  final Gs1FieldScanKind kind;
  final ValueChanged<String> onScanned;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const TraqIcon(AppAssets.iconQr),
      tooltip: 'Scan barcode',
      onPressed: () async {
        final value = await Gs1FieldBarcodeScan.scan(context, kind);
        if (value != null) onScanned(value);
      },
    );
  }
}
