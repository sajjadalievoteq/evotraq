import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_resolved_epc_chip.dart';

/// Step 1 — single EPC input with auto-detection (replaces GTIN selector).
class CommissioningIdentifyEpcCard extends StatelessWidget {
  const CommissioningIdentifyEpcCard({
    super.key,
    required this.onEpcResolved,
    this.resolvedParsed,
    this.sourceStatus,
    this.targetStatus,
    this.parseError,
    this.gtinMismatchMessage,
    this.guessabilityWarning,
    this.isResolving = false,
    this.manualFallbackEnabled = false,
    this.onManualFallbackToggled,
    this.onParseFallback,
  });

  final void Function(EPCParseResult result, {required bool isManual}) onEpcResolved;
  final EPCParseResult? resolvedParsed;
  final String? sourceStatus;
  final String? targetStatus;
  final String? parseError;
  final String? gtinMismatchMessage;
  final String? guessabilityWarning;
  final bool isResolving;
  final bool manualFallbackEnabled;
  final ValueChanged<bool>? onManualFallbackToggled;
  final Future<EPCParseResult?> Function(String input)? onParseFallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Gs1GroupCard(
      title: 'Identify Product / Container',
      showRequiredStar: true,
      outlineColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Scan or enter a complete SGTIN, SSCC, GS1 element string, or bare serial. '
            'Type is detected automatically.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          EPCInputWidget(
            label: 'EPC / Barcode',
            placeholder: 'SGTIN, SSCC, (01)(21)…, (00)…, or bare serial',
            allowedTypes: const [EPCType.sgtin, EPCType.sscc],
            onParseFallback: onParseFallback,
            onItemAdded: (result) => onEpcResolved(result, isManual: false),
          ),
          if (onManualFallbackToggled != null) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Manual entry fallback'),
              subtitle: const Text(
                'Type identifiers manually when scanning is unavailable. '
                'Pool validation still applies.',
              ),
              value: manualFallbackEnabled,
              onChanged: onManualFallbackToggled,
            ),
            if (manualFallbackEnabled)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Manual entry mode — verify each identifier carefully. '
                          'Only pre-allocated serials can be commissioned.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (isResolving) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (parseError != null) ...[
            const SizedBox(height: 8),
            Text(
              parseError!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ],
          if (resolvedParsed != null) ...[
            const SizedBox(height: 12),
            CommissioningResolvedEpcChip(
              parsed: resolvedParsed!,
              sourceStatus: sourceStatus,
              targetStatus: targetStatus,
            ),
          ],
          if (gtinMismatchMessage != null) ...[
            const SizedBox(height: 8),
            _warningBanner(context, gtinMismatchMessage!, Colors.red.shade50),
          ],
          if (guessabilityWarning != null) ...[
            const SizedBox(height: 8),
            _warningBanner(context, guessabilityWarning!, Colors.amber.shade50),
          ],
        ],
      ),
    );
  }

  Widget _warningBanner(BuildContext context, String message, Color bg) {
    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
