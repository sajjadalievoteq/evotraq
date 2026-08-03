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
  });

  final String title;
  final Widget child;
  final WorkbenchInstructions? instructions;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SelectionArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          context.padding.top,
          context.padding.top,
          context.padding.top,
        ),
        children: [
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
          Card(
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
          ),
        ],
      ),
    );
  }
}
