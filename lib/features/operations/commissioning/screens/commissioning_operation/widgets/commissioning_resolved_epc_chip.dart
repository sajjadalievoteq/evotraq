import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

/// Shows detected type, canonical EPC URI, identifiers, and check-digit validity.
class CommissioningResolvedEpcChip extends StatelessWidget {
  const CommissioningResolvedEpcChip({
    super.key,
    required this.parsed,
    this.sourceStatus,
    this.targetStatus,
  });

  final EPCParseResult parsed;
  final String? sourceStatus;
  final String? targetStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  label: Text(parsed.typeLabel),
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                ),
                if (sourceStatus != null && targetStatus != null)
                  Chip(
                    avatar: Icon(Icons.swap_horiz, size: 16, color: colorScheme.primary),
                    label: Text('$sourceStatus → $targetStatus'),
                  ),
                _checkDigitChip(context),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              parsed.epc,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            if (parsed.gtin != null) ...[
              const SizedBox(height: 4),
              Text('GTIN: ${parsed.gtin}', style: theme.textTheme.bodySmall),
            ],
            if (parsed.serial != null) ...[
              const SizedBox(height: 4),
              Text('Serial: ${parsed.serial}', style: theme.textTheme.bodySmall),
            ],
            if (parsed.sscc != null) ...[
              const SizedBox(height: 4),
              Text('SSCC: ${parsed.sscc}', style: theme.textTheme.bodySmall),
            ],
            if (parsed.companyPrefix != null) ...[
              const SizedBox(height: 4),
              Text(
                'Company prefix: ${parsed.companyPrefix}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Format: ${parsed.detectedFormat}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkDigitChip(BuildContext context) {
    final theme = Theme.of(context);
    final valid = _checkDigitValid;
    return Chip(
      avatar: Icon(
        valid == true ? Icons.check_circle : Icons.error_outline,
        size: 16,
        color: valid == true ? Colors.green.shade700 : theme.colorScheme.error,
      ),
      label: Text(
        valid == null
            ? 'Check digit N/A'
            : valid
                ? 'Check digit valid'
                : 'Invalid check digit',
      ),
      backgroundColor: (valid == true ? Colors.green : theme.colorScheme.error)
          .withValues(alpha: 0.1),
    );
  }

  bool? get _checkDigitValid {
    if (parsed.gtin != null) {
      return GtinFormat.isValidGtin(parsed.gtin!);
    }
    if (parsed.sscc != null) {
      return SsccFormat.isValidSscc(parsed.sscc!);
    }
    if (parsed.type == EPCType.sscc && parsed.epc.startsWith('urn:epc:id:sscc:')) {
      return null;
    }
    return null;
  }
}
