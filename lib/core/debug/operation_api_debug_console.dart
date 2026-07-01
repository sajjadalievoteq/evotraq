import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/debug/operation_api_debug_trace.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Scrollable dialog that shows full request/response details for an operation API call.
abstract final class OperationApiDebugConsole {
  OperationApiDebugConsole._();

  static Future<void> show(
    BuildContext context,
    OperationApiDebugTrace trace, {
    String title = 'API Debug Console',
  }) async {
    OperationApiDebugTrace.remember(trace);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _OperationApiDebugDialog(
        title: title,
        trace: trace,
      ),
    );
  }
}

class _OperationApiDebugDialog extends StatelessWidget {
  const _OperationApiDebugDialog({
    required this.title,
    required this.trace,
  });

  final String title;
  final OperationApiDebugTrace trace;

  Future<void> _copy(BuildContext context, String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    context.showSuccess('Copied $label');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (trace.statusCode) {
      null => theme.colorScheme.outline,
      >= 200 && < 300 => theme.colorScheme.primary,
      >= 400 && < 500 => theme.colorScheme.tertiary,
      _ => theme.colorScheme.error,
    };

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  TraqIcon(AppAssets.iconFlask, color: statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          trace.operation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy full report',
                    onPressed: () =>
                        _copy(context, 'full report', trace.fullReport()),
                    icon: const TraqIcon(AppAssets.iconCopy),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: TraqIcon(AppAssets.iconX),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryCard(trace: trace, statusColor: statusColor),
                  if (trace.validationNotes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(
                      title: 'Client validation',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: trace.validationNotes
                            .map(
                              (n) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(child: Text(n)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Request',
                    trailing: IconButton(
                      tooltip: 'Copy request body',
                      icon: const TraqIcon(AppAssets.iconCopy, size: 18),
                      onPressed: () => _copy(
                        context,
                        'request body',
                        trace.prettyRequestBody(),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${trace.method} ${trace.url}'),
                        const SizedBox(height: 8),
                        Text(
                          'Headers',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        _CodeBlock(
                          text: trace.requestHeaders.entries
                              .map((e) => '${e.key}: ${e.value}')
                              .join('\n'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Body',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        _CodeBlock(text: trace.prettyRequestBody()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Response',
                    trailing: IconButton(
                      tooltip: 'Copy response body',
                      icon: const TraqIcon(AppAssets.iconCopy, size: 18),
                      onPressed: () => _copy(
                        context,
                        'response body',
                        trace.prettyResponseBody(),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HTTP ${trace.statusCode ?? '—'}'),
                        if (trace.errorId != null)
                          Text('Error ID: ${trace.errorId}'),
                        if (trace.errorCode != null)
                          Text('Code: ${trace.errorCode}'),
                        if (trace.serverMessage != null) ...[
                          const SizedBox(height: 4),
                          Text(trace.serverMessage!),
                        ],
                        const SizedBox(height: 8),
                        _CodeBlock(text: trace.prettyResponseBody()),
                      ],
                    ),
                  ),
                  if (trace.stackTrace != null &&
                      trace.stackTrace!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(
                      title: 'Stack trace',
                      child: _CodeBlock(text: trace.stackTrace!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.trace,
    required this.statusColor,
  });

  final OperationApiDebugTrace trace;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: statusColor.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trace.errorMessage ?? 'Request completed',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${trace.method} ${trace.url}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Status ${trace.statusCode ?? '—'}'
              '${trace.durationMs != null ? ' · ${trace.durationMs} ms' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              trace.timestamp.toLocal().toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
      ),
    );
  }
}