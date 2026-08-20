import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SubscriptionDetailRow extends StatelessWidget {
  const SubscriptionDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
    this.copyable = false,
  });

  final String label;
  final String value;

  /// Use the theme's monospace style for the value — for technical values
  /// like webhook URLs, GLNs, and EPC patterns.
  final bool monospace;

  /// Show a copy-to-clipboard affordance next to the value.
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final valueStyle = monospace
        ? context.text.mono
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.md,
        vertical: TraqSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: valueStyle),
          ),
          if (copyable) ...[
            const SizedBox(width: TraqSpacing.sm),
            InkWell(
              borderRadius: TraqRadius.chip,
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                context.showInfo('Copied to clipboard');
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: TraqIcon(
                  AppAssets.iconCopy,
                  size: 14,
                  color: context.colors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
