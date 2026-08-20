import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';

/// Shared Automation Center panel chrome: one outer scroll for title,
/// instructions, and intrinsic-height body (no nested expand/scroll).
///
/// Text selection comes from the route-level [SelectionArea]. Nested
/// [SelectionArea] widgets throw `_selectable == null`.
class AutomationWorkbenchPanel extends StatelessWidget {
  const AutomationWorkbenchPanel({
    super.key,
    required this.title,
    required this.child,
    this.instructions,
    this.actions = const [],
    this.fillBody = false,
  });

  final String title;
  final Widget child;
  final WorkbenchInstructions? instructions;
  final List<Widget> actions;

  /// When true, the body card fills the remaining panel height. The header and
  /// body participate in one coordinated right-pane scroll, so scrolling a
  /// long body also scrolls the panel chrome instead of trapping the pointer
  /// inside the card.
  final bool fillBody;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pad = context.padding.top;

    final titleText = Text(
      title,
      style: context.text.h2,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    final actionWrap = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      spacing: TraqSpacing.sm,
      runSpacing: TraqSpacing.sm,
      children: actions,
    );
    final compact = !context.layout.isDesktopUp;
    final header = <Widget>[
      if (compact)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titleText,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: TraqSpacing.sm),
              Align(alignment: Alignment.centerRight, child: actionWrap),
            ],
          ],
        )
      else
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleText),
            if (actions.isNotEmpty) ...[
              const SizedBox(width: TraqSpacing.sm),
              Flexible(child: actionWrap),
            ],
          ],
        ),
      const SizedBox(height: TraqSpacing.md),
      if (instructions != null) ...[
        WorkbenchInstructionsCard(instructions: instructions!),
        const SizedBox(height: TraqSpacing.md),
      ],
    ];

    final card = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: TraqSpacing.surfacePad, child: child),
    );

    if (fillBody) {
      return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              context.gutter,
              context.gutter,
              context.gutter,
              0,
            ),
            sliver: SliverList.list(children: header),
          ),
        ],
        body: Padding(
          padding: EdgeInsets.fromLTRB(context.gutter, 0, context.gutter, 0),
          child: Column(
            children: [
              Expanded(child: card),
              SizedBox(height: context.gutter),
            ],
          ),
        ),
      );
    }

    return ListView(padding: EdgeInsets.all(pad), children: [...header, card]);
  }
}
