import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class WorkbenchPanelShell extends StatelessWidget {
  const WorkbenchPanelShell({
    super.key,
    required this.title,
    required this.child,
    required this.slice,
    this.actions = const [],
    this.expandBody = false,
  });

  final String title;
  final Widget child;
  final WorkbenchSlice slice;
  final List<Widget> actions;

  /// When true, [child] fills remaining height (for nested CRUD/list UIs).
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleBlock = Text(title, style: context.text.h2);
    final formCard = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: colors.border),
      ),
      child: expandBody
          ? child
          : Padding(
              padding: TraqSpacing.cardPad,
              child: child,
            ),
    );
    final statusBlocks = <Widget>[
      if (actions.isNotEmpty) ...[
        const SizedBox(height: TraqSpacing.md),
        Wrap(
          spacing: TraqSpacing.sm,
          runSpacing: TraqSpacing.sm,
          children: actions,
        ),
      ],
      if (slice.isLoading) ...[
        const SizedBox(height: TraqSpacing.lg),
        const Center(child: CircularProgressIndicator()),
      ],
      if (slice.hasError) ...[
        const SizedBox(height: TraqSpacing.lg),
        _StatusBanner(
          color: colors.error,
          icon: AppAssets.iconAlert,
          text: slice.error ?? 'Something went wrong',
        ),
      ],
      if (slice.hasResult) ...[
        const SizedBox(height: TraqSpacing.lg),
        _ResultCard(slice: slice),
      ],
    ];

    if (expandBody) {
      return SelectionArea(
        child: Padding(
          padding: const EdgeInsets.all(TraqSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              const SizedBox(height: TraqSpacing.md),
              Expanded(child: formCard),
              ...statusBlocks,
            ],
          ),
        ),
      );
    }

    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        children: [
          titleBlock,
          const SizedBox(height: TraqSpacing.md),
          formCard,
          ...statusBlocks,
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.slice});

  final WorkbenchSlice slice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: TraqSpacing.cardPad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Result', style: context.text.h3),
                const Spacer(),
                if (slice.resultText != null)
                  IconButton(
                    tooltip: 'Copy',
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: slice.resultText!),
                      );
                      if (context.mounted) {
                        context.showSuccess('Copied to clipboard');
                      }
                    },
                    icon: TraqIcon(AppAssets.iconCopy, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: TraqSpacing.sm),
            if (slice.imageBytes != null)
              Center(
                child: Image.memory(
                  slice.imageBytes!,
                  fit: BoxFit.contain,
                  height: 220,
                ),
              ),
            if (slice.resultFields.isNotEmpty)
              ...slice.resultFields.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 160,
                        child: Text(
                          e.key,
                          style: context.text.bodySm.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(e.value, style: context.text.body),
                      ),
                    ],
                  ),
                ),
              )
            else if (slice.resultText != null)
              Text(slice.resultText!, style: context.text.body),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.text,
  });

  final Color color;
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TraqSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          TraqIcon(icon, color: color, size: 16),
          const SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: context.text.body.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
