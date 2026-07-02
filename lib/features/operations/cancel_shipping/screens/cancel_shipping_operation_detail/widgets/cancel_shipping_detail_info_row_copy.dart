import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';

/// Copyable label/value row for shipping detail cards.
class CancelShippingDetailInfoRowCopy extends StatelessWidget {
  const CancelShippingDetailInfoRowCopy({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: SgtinInfoRow(label, value, monospace: true)),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              context.showSuccess('Copied', duration: const Duration(seconds: 1));
            },
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: TraqIcon(AppAssets.iconCopy, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
