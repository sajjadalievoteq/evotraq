import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JourneyProductEpcRow extends StatefulWidget {
  const JourneyProductEpcRow({super.key, required this.epc});
  final String epc;

  @override
  State<JourneyProductEpcRow> createState() => _JourneyProductEpcRowState();
}

class _JourneyProductEpcRowState extends State<JourneyProductEpcRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final display = _expanded
        ? widget.epc
        : (widget.epc.length > 36
              ? '${widget.epc.substring(0, 36)}…'
              : widget.epc);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EPC URI',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () => setState(() => _expanded = !_expanded),
                child: SelectableText(
                  display,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: colors.textPrimary,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Copy EPC',
              icon: TraqIcon(
                AppAssets.iconCopy,
                size: 16,
                color: colors.textMuted,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.epc));
                context.showSuccess('EPC copied');
              },
            ),
          ],
        ),
      ],
    );
  }
}
