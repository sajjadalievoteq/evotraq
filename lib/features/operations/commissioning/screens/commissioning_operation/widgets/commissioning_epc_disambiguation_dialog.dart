import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_pool_match.dart';

/// Prompts the operator to pick one pool record when a bare serial is ambiguous.
class CommissioningEpcDisambiguationDialog extends StatelessWidget {
  const CommissioningEpcDisambiguationDialog({
    super.key,
    required this.serial,
    required this.matches,
  });

  final String serial;
  final List<CommissioningPoolMatch> matches;

  static Future<CommissioningPoolMatch?> show(
    BuildContext context, {
    required String serial,
    required List<CommissioningPoolMatch> matches,
  }) {
    return showDialog<CommissioningPoolMatch>(
      context: context,
      builder: (_) => CommissioningEpcDisambiguationDialog(
        serial: serial,
        matches: matches,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ambiguous serial'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Serial "$serial" matches ${matches.length} pre-allocated records. '
              'Select the correct identifier:',
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: matches.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return ListTile(
                    title: Text(match.label),
                    subtitle: Text(
                      match.parsed.epc,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                    onTap: () => Navigator.of(context).pop(match),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
