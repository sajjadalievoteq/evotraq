import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_result_card.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_status_banner.dart';

class WorkbenchPanelShell extends StatelessWidget {
  const WorkbenchPanelShell({
    super.key,
    required this.title,
    required this.child,
    required this.slice,
    this.actions = const [],
    this.expandBody = false,
    this.instructions,
    this.onLoadExample,
  });

  final String title;
  final Widget child;
  final WorkbenchSlice slice;
  final List<Widget> actions;

  /// When true, [child] fills remaining height (for nested CRUD/list UIs).
  final bool expandBody;

  final WorkbenchInstructions? instructions;
  final WorkbenchExampleLoader? onLoadExample;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleBlock = Text(title, style: context.text.h2);
    final instructionsBlock = instructions == null
        ? null
        : Padding(
            padding: EdgeInsets.only(bottom: context.padding.top),
            child: WorkbenchInstructionsCard(
              instructions: instructions!,
              onLoadExample: onLoadExample,
            ),
          );
    final formCard = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: colors.border),
      ),
      child: expandBody
          ? child
          : Padding(padding: TraqSpacing.cardPad, child: child),
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
        WorkbenchStatusBanner(
          color: colors.error,
          icon: AppAssets.iconAlert,
          text: slice.error ?? 'Something went wrong',
        ),
      ],
      if (slice.hasResult) ...[
        const SizedBox(height: TraqSpacing.lg),
        WorkbenchResultCard(slice: slice),
      ],
    ];

    if (expandBody) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          context.padding.top,
          context.padding.top,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titleBlock,
            const SizedBox(height: TraqSpacing.md),
            if (instructionsBlock != null) instructionsBlock,
            Expanded(child: formCard),
            ...statusBlocks,
            SizedBox(height: context.padding.top),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.padding.top,
        context.padding.top,
        context.padding.top,
        0,
      ),
      children: [
        titleBlock,
        const SizedBox(height: TraqSpacing.md),
        if (instructionsBlock != null) instructionsBlock,
        formCard,
        ...statusBlocks,
        SizedBox(height: context.padding.top),
      ],
    );
  }
}
