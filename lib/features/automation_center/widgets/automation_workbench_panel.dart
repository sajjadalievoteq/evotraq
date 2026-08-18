import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';

/// Shared Automation Center panel chrome: one outer scroll for title,
/// instructions, and intrinsic-height body (no nested expand/scroll).
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

    final header = <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(title, style: context.text.h2)),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: TraqSpacing.sm),
            SizedBox(
              height: 30,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.end,
                spacing: TraqSpacing.sm,
                runSpacing: TraqSpacing.sm,
                children: actions,
              ),
            ),
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
      return SelectionArea(
        child: NestedScrollView(
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
            padding: EdgeInsets.fromLTRB(
              context.gutter,
              0,
              context.gutter,
           0,
            ),
            child: Column(
              children: [
                Expanded(child: card),
                SizedBox(height: context.gutter,)
              ],
            ),
          ),
        ),
      );
    }

    return SelectionArea(
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [...header, card],
      ),
    );
  }
}
