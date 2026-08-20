import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_types.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CustomSnackbarContent extends StatelessWidget {
  final CustomSnackBarVariant variant;
  final String message;
  final String? title;
  final VoidCallback? onClose;

  const CustomSnackbarContent({
    super.key,
    required this.variant,
    required this.message,
    this.title,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tone = variant.color(context);
    final ec = context.colors;

    final surface = ec.surface;
    final text = ec.textPrimary;
    final subText = ec.textMuted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withOpacity(isDark ? 0.35 : 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tone.withOpacity(isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TraqIcon(variant.iconAsset, color: tone, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null && title!.trim().isNotEmpty) ...[
                    Text(
                      title!.trim(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: text,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: title == null ? text : subText,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onClose,
              icon: TraqIcon(
                AppAssets.iconX,
                size: 18,
                color: subText.withOpacity(0.9),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
