import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/partial_success/commissioning_partial_success_choice.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/partial_success/commissioning_partial_success_result.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/partial_success/commissioning_partial_success_summary_row.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/models/commissioning_failure_category.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_failure_analysis.dart';

Future<CommissioningPartialSuccessResult?> showPartialSuccessDialog(
  BuildContext context,
  CommissioningResponse response,
) {
  return showDialog<CommissioningPartialSuccessResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => CommissioningPartialSuccessDialog(response: response),
  );
}

class CommissioningPartialSuccessDialog extends StatefulWidget {
  const CommissioningPartialSuccessDialog({super.key, required this.response});

  final CommissioningResponse response;

  @override
  State<CommissioningPartialSuccessDialog> createState() =>
      _CommissioningPartialSuccessDialogState();
}

class _CommissioningPartialSuccessDialogState
    extends State<CommissioningPartialSuccessDialog> {
  late final Map<CommissioningFailureCategory, List<CommissioningItemResult>>
      _grouped;
  late final Set<String> _serialsMarkedForRemoval;

  @override
  void initState() {
    super.initState();
    final results = widget.response.itemResults ?? [];
    _grouped = groupFailedCommissioningResults(results);
    _serialsMarkedForRemoval = {};
    for (final entry in _grouped.entries) {
      final info = categoryInfo(entry.key);
      if (info.defaultRemoveFromOperation) {
        for (final item in entry.value) {
          _serialsMarkedForRemoval.add(item.serialNumber);
        }
      }
    }
  }

  int get _failedCount => widget.response.failedCount ??
      (widget.response.itemResults?.where((r) => !r.success).length ?? 0);

  int get _successCount => widget.response.commissionedCount ??
      (widget.response.itemResults?.where((r) => r.success).length ?? 0);

  void _toggleSerial(String serial, bool selected) {
    setState(() {
      if (selected) {
        _serialsMarkedForRemoval.add(serial);
      } else {
        _serialsMarkedForRemoval.remove(serial);
      }
    });
  }

  void _toggleCategory(CommissioningFailureCategory category, bool selected) {
    setState(() {
      for (final item in _grouped[category] ?? []) {
        if (selected) {
          _serialsMarkedForRemoval.add(item.serialNumber);
        } else {
          _serialsMarkedForRemoval.remove(item.serialNumber);
        }
      }
    });
  }

  void _pop(CommissioningPartialSuccessChoice choice) {
    Navigator.of(context).pop(
      CommissioningPartialSuccessResult(
        choice: choice,
        serialsMarkedForRemoval: Set<String>.from(_serialsMarkedForRemoval),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: c.warning),
          const SizedBox(width: 10),
          const Expanded(child: Text('Partial success')),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_successCount item(s) were commissioned successfully, but '
                '$_failedCount item(s) failed. Partial success means the batch '
                'completed with a mix of successes and failures — usually because '
                'some serials were duplicates, already commissioned, or failed validation.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: c.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              CommissioningPartialSuccessSummaryRow(
                label: 'Commissioned',
                value: '$_successCount',
                color: c.success,
              ),
              CommissioningPartialSuccessSummaryRow(
                label: 'Failed',
                value: '$_failedCount',
                color: c.error,
              ),
              const SizedBox(height: 20),
              Text(
                'Why some items failed',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (_grouped.isEmpty)
                Text(
                  'No per-item error details were returned by the server.',
                  style: TextStyle(color: c.textSecondary),
                )
              else
                ..._grouped.entries.map((entry) {
                  final info = categoryInfo(entry.key);
                  final items = entry.value;
                  final allSelected = items.every(
                    (i) => _serialsMarkedForRemoval.contains(i.serialNumber),
                  );
                  final someSelected = items.any(
                    (i) => _serialsMarkedForRemoval.contains(i.serialNumber),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: allSelected
                                  ? true
                                  : (someSelected ? null : false),
                              tristate: true,
                              onChanged: (v) => _toggleCategory(
                                entry.key,
                                v ?? false,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    info.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    info.explanation,
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ...items.map(
                          (item) => CheckboxListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.only(left: 16),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _serialsMarkedForRemoval
                                .contains(item.serialNumber),
                            onChanged: (v) =>
                                _toggleSerial(item.serialNumber, v ?? false),
                            title: Text(
                              item.serialNumber,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              item.errorMessage ?? 'Unknown error',
                              style: TextStyle(
                                color: c.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 8),
              Text(
                'Checked serials will be removed from this operation. You can '
                'retry the remaining failed serials, continue editing without '
                'removing them, or accept the partial batch as-is.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: c.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () =>
              _pop(CommissioningPartialSuccessChoice.acceptPartialSuccess),
          child: const Text('Accept partial success'),
        ),
        TextButton(
          onPressed: () =>
              _pop(CommissioningPartialSuccessChoice.continueWithoutRemoving),
          child: const Text('Continue without removing'),
        ),
        FilledButton(
          onPressed: () =>
              _pop(CommissioningPartialSuccessChoice.removeSelectedAndRetry),
          child: const Text('Remove selected & retry'),
        ),
      ],
    );
  }
}
