import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Per-tool help shown at the top of [WorkbenchPanelShell].
class WorkbenchInstructions {
  const WorkbenchInstructions({
    required this.summary,
    required this.useCase,
    this.steps = const [],
    this.exampleInput,
    this.exampleNote,
    this.audience,
  });

  /// One line: what it does.
  final String summary;

  /// One line: when/why you'd use it + who.
  final String useCase;

  /// 2–4 short how-to steps.
  final List<String> steps;

  /// Sample input (optional) — prefills via Load example only.
  final String? exampleInput;

  /// What the example shows (optional).
  final String? exampleNote;

  /// Informational tag, e.g. `'Everyday'` or `'Advanced / Integrator'`.
  final String? audience;
}

typedef WorkbenchExampleLoader = void Function(String exampleInput);

/// Compact, theme-aware instructions card with use-case + collapsible how-to.
class WorkbenchInstructionsCard extends StatelessWidget {
  const WorkbenchInstructionsCard({
    super.key,
    required this.instructions,
    this.onLoadExample,
  });

  final WorkbenchInstructions instructions;
  final WorkbenchExampleLoader? onLoadExample;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final muted = colors.onSurfaceVariant;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hasHowTo = instructions.steps.isNotEmpty ||
        (instructions.exampleInput != null &&
            instructions.exampleInput!.isNotEmpty);

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TraqIcon(AppAssets.iconHelpCircle, size: 18, color: muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        instructions.summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: muted,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        instructions.useCase,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
          if (hasHowTo) ...[
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashFactory: reduceMotion
                    ? NoSplash.splashFactory
                    : Theme.of(context).splashFactory,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.only(bottom: 4,left: 16,right: 16),
                title: Text(
                  'How to use',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: muted,
                      ),
                ),
                children: [
                  for (final step in instructions.steps)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: muted)),
                          Expanded(
                            child: Text(
                              step,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (instructions.exampleInput != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Example input',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                    ),
                    const SizedBox(height: 2),
                    SelectableText(
                      instructions.exampleInput!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                    if (instructions.exampleNote != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          instructions.exampleNote!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: muted),
                        ),
                      ),
                    if (onLoadExample != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: () =>
                              onLoadExample!(instructions.exampleInput!),
                          child: const Text('Load example'),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
