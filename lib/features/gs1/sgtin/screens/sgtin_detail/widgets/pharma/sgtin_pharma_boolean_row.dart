import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SgtinPharmaBooleanRow extends StatelessWidget {
  const SgtinPharmaBooleanRow(
    this.label,
    this.value, {
    this.trueColor,
    this.falseColor,
    super.key,
  });

  final String label;
  final bool value;
  final Color? trueColor;
  final Color? falseColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = value
        ? (trueColor ?? AppColorMapper.successColor(context))
        : (falseColor ?? Colors.grey);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 190,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TraqIcon(
          value ? AppAssets.iconCheckCircle : AppAssets.iconXCircle,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          value ? 'Yes' : 'No',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
