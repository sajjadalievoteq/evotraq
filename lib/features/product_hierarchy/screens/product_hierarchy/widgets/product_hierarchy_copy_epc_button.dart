import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ProductHierarchyCopyEpcButton extends StatelessWidget {
  const ProductHierarchyCopyEpcButton({
    super.key,
    required this.epc,
    required this.iconColor,
  });

  final String epc;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: TraqIcon(AppAssets.iconCopy, size: 16, color: iconColor),
      tooltip: 'Copy EPC',
      visualDensity: VisualDensity.compact,
      onPressed: () {
        Clipboard.setData(ClipboardData(text: epc));
        context.showSuccess('EPC copied', duration: const Duration(seconds: 1));
      },
    );
  }
}
