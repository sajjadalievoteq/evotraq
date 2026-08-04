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

  /// When true, the body card fills the remaining panel height instead of
  /// sizing to its intrinsic content. Use for panels whose body should stretch
  /// to the bottom (e.g. an empty state that centers in the available space).
  /// The body is then responsible for scrolling its own overflowing content.
  final bool fillBody;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pad = context.padding.top;

    final header = <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(title, style: context.text.h2),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: TraqSpacing.sm),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.end,
              spacing: TraqSpacing.sm,
              runSpacing: TraqSpacing.sm,
              children: actions,
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
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: child,
      ),
    );

    if (fillBody) {
      // Pinned header + card that expands to fill the remaining height. The
      // panel area is bounded (WorkbenchScaffold hands it an Expanded), so the
      // card gets a bounded height and its body can stretch to the bottom.
      return SelectionArea(
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...header,
              Expanded(child: card),
            ],
          ),
        ),
      );
    }

    return SelectionArea(
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          ...header,
          card,
        ],
      ),
    );
  }
}
