import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';

class AutomationWorkbenchPanel extends StatelessWidget {
  const AutomationWorkbenchPanel({
    super.key,
    required this.title,
    this.child,
    this.bodySlivers,
    this.instructions,
    this.actions = const [],
    this.onScrollNotification,
  }) : assert(
          child != null || bodySlivers != null,
          'Provide child and/or bodySlivers',
        );

  final String title;

  final Widget? child;

  final List<Widget>? bodySlivers;

  final WorkbenchInstructions? instructions;
  final List<Widget> actions;

  final bool Function(ScrollNotification notification)? onScrollNotification;

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

    final cardDecoration = ShapeDecoration(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: colors.border),
      ),
    );

    final innerSlivers = <Widget>[
      ?SliverToBoxAdapter(child: child),
      ...?bodySlivers,
    ];

    final scrollView = CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          sliver: SliverList.list(children: header),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
          sliver: DecoratedSliver(
            decoration: cardDecoration,
            sliver: SliverPadding(
              padding: TraqSpacing.surfacePad,
              sliver: MultiSliver(children: innerSlivers),
            ),
          ),
        ),
      ],
    );

    if (onScrollNotification == null) return scrollView;
    return NotificationListener<ScrollNotification>(
      onNotification: onScrollNotification,
      child: scrollView,
    );
  }
}

class MultiSliver extends StatelessWidget {
  const MultiSliver({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: children);
  }
}
